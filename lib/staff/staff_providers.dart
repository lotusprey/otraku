import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/discover/discover_models.dart';
import 'package:otraku/common/relation.dart';
import 'package:otraku/staff/staff_models.dart';
import 'package:otraku/utils/api.dart';
import 'package:otraku/utils/convert.dart';
import 'package:otraku/utils/graphql.dart';
import 'package:otraku/common/paged.dart';
import 'package:otraku/utils/options.dart';

/// Favorite/Unfavorite staff. Returns `true` if successful.
Future<bool> toggleFavoriteStaff(int staffId) async {
  try {
    await Api.get(GqlMutation.toggleFavorite, {'staff': staffId});
    return true;
  } catch (_) {
    return false;
  }
}

final staffProvider = FutureProvider.autoDispose.family(
  (ref, int id) async {
    final data = await Api.get(
      GqlQuery.staff,
      {'id': id, 'withInfo': true},
    );
    return Staff(data['Staff']);
  },
);

final staffFilterProvider =
    StateProvider.autoDispose.family((ref, _) => StaffFilter());

final staffRelationsProvider = StateNotifierProvider.autoDispose
    .family<StaffRelationNotifier, StaffRelations, int>(
  (ref, int id) =>
      StaffRelationNotifier(id, ref.watch(staffFilterProvider(id))),
);

class StaffRelationNotifier extends StateNotifier<StaffRelations> {
  StaffRelationNotifier(this.id, this.filter) : super(const StaffRelations()) {
    _fetch(null);
  }

  final int id;
  final StaffFilter filter;

  Future<void> fetch(bool onCharacters) => _fetch(onCharacters);

  Future<void> _fetch(bool? onCharacters) async {
    final variables = <String, dynamic>{
      'id': id,
      'onList': filter.onList,
      'sort': filter.sort.name,
      if (filter.ofAnime != null) 'type': filter.ofAnime! ? 'ANIME' : 'MANGA',
    };

    if (onCharacters == null) {
      variables['withCharacters'] = true;
      variables['withRoles'] = true;
    } else if (onCharacters) {
      if (!(state.characters.valueOrNull?.hasNext ?? true)) return;
      variables['withCharacters'] = true;
      variables['page'] = state.characters.valueOrNull?.next ?? 1;
    } else {
      if (!(state.roles.valueOrNull?.hasNext ?? true)) return;
      variables['withRoles'] = true;
      variables['page'] = state.roles.valueOrNull?.next ?? 1;
    }

    final data = await AsyncValue.guard<Map<String, dynamic>>(() async {
      final data = await Api.get(GqlQuery.staff, variables);
      return data['Staff'];
    });

    var characters = state.characters;
    var roles = state.roles;
    var characterMedia = [...state.characterMedia];

    if (onCharacters == null || onCharacters) {
      characters = await AsyncValue.guard(() {
        if (data.hasError) throw data.error!;
        final map = data.value!['characterMedia'];
        final value = characters.valueOrNull ?? const Paged();

        final items = <Relation>[];
        for (final m in map['edges']) {
          final media = Relation(
            id: m['node']['id'],
            title: m['node']['title']['userPreferred'],
            imageUrl: m['node']['coverImage'][Options().imageQuality.value],
            subtitle: Convert.clarifyEnum(m['node']['format']),
            type: m['node']['type'] == 'ANIME'
                ? DiscoverType.anime
                : DiscoverType.manga,
          );

          for (final c in m['characters']) {
            if (c == null) continue;

            characterMedia.add(media);

            items.add(Relation(
              id: c['id'],
              title: c['name']['userPreferred'],
              imageUrl: c['image']['large'],
              type: DiscoverType.character,
              subtitle: Convert.clarifyEnum(m['characterRole']),
            ));
          }
        }

        return Future.value(value.withNext(
          items,
          map['pageInfo']['hasNextPage'] ?? false,
        ));
      });
    }

    if (onCharacters == null || !onCharacters) {
      roles = await AsyncValue.guard(() {
        if (data.hasError) throw data.error!;
        final map = data.value!['staffMedia'];
        final value = roles.valueOrNull ?? const Paged();

        final items = <Relation>[];
        for (final s in map['edges']) {
          items.add(Relation(
            id: s['node']['id'],
            title: s['node']['title']['userPreferred'],
            imageUrl: s['node']['coverImage'][Options().imageQuality.value],
            subtitle: s['staffRole'],
            type: s['node']['type'] == 'ANIME'
                ? DiscoverType.anime
                : DiscoverType.manga,
          ));
        }

        return Future.value(value.withNext(
          items,
          map['pageInfo']['hasNextPage'] ?? false,
        ));
      });
    }

    state = StaffRelations(
      characters: characters,
      roles: roles,
      characterMedia: characterMedia,
    );
  }
}
