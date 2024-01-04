import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/common/models/paged.dart';
import 'package:otraku/common/models/relation.dart';
import 'package:otraku/common/utils/api.dart';
import 'package:otraku/common/utils/extensions.dart';
import 'package:otraku/common/utils/graphql.dart';
import 'package:otraku/common/utils/image_quality.dart';
import 'package:otraku/modules/discover/discover_models.dart';
import 'package:otraku/modules/staff/staff_models.dart';

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
      if (!(state.charactersAndMedia.valueOrNull?.hasNext ?? true)) return;
      variables['withCharacters'] = true;
      variables['page'] = state.charactersAndMedia.valueOrNull?.next ?? 1;
    } else {
      if (!(state.roles.valueOrNull?.hasNext ?? true)) return;
      variables['withRoles'] = true;
      variables['page'] = state.roles.valueOrNull?.next ?? 1;
    }

    final data = await AsyncValue.guard<Map<String, dynamic>>(() async {
      final data = await Api.get(GqlQuery.staff, variables);
      return data['Staff'];
    });

    var charactersAndMedia = state.charactersAndMedia;
    var roles = state.roles;

    if (onCharacters == null || onCharacters) {
      charactersAndMedia = await AsyncValue.guard(() {
        if (data.hasError) throw data.error!;
        final map = data.value!['characterMedia'];
        final value = charactersAndMedia.valueOrNull ?? const Paged();

        final items = <(Relation, Relation)>[];
        for (final m in map['edges']) {
          final media = Relation(
            id: m['node']['id'],
            title: m['node']['title']['userPreferred'],
            imageUrl: m['node']['coverImage'][imageQuality],
            subtitle: StringUtil.tryNoScreamingSnakeCase(m['node']['format']),
            type: m['node']['type'] == 'ANIME'
                ? DiscoverType.Anime
                : DiscoverType.Manga,
          );

          for (final c in m['characters']) {
            if (c == null) continue;

            items.add((
              Relation(
                id: c['id'],
                title: c['name']['userPreferred'],
                imageUrl: c['image']['large'],
                type: DiscoverType.Character,
                subtitle: StringUtil.tryNoScreamingSnakeCase(
                  m['characterRole'],
                ),
              ),
              media,
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
            imageUrl: s['node']['coverImage'][imageQuality],
            subtitle: s['staffRole'],
            type: s['node']['type'] == 'ANIME'
                ? DiscoverType.Anime
                : DiscoverType.Manga,
          ));
        }

        return Future.value(value.withNext(
          items,
          map['pageInfo']['hasNextPage'] ?? false,
        ));
      });
    }

    state = StaffRelations(
      charactersAndMedia: charactersAndMedia,
      roles: roles,
    );
  }
}
