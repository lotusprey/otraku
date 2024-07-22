import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/extension/future_extension.dart';
import 'package:otraku/extension/string_extension.dart';
import 'package:otraku/feature/staff/staff_filter_model.dart';
import 'package:otraku/feature/discover/discover_models.dart';
import 'package:otraku/model/relation.dart';
import 'package:otraku/feature/settings/settings_provider.dart';
import 'package:otraku/feature/staff/staff_filter_provider.dart';
import 'package:otraku/feature/staff/staff_model.dart';
import 'package:otraku/feature/viewer/repository_provider.dart';
import 'package:otraku/util/graphql.dart';
import 'package:otraku/util/persistence.dart';

final staffProvider =
    AsyncNotifierProvider.autoDispose.family<StaffNotifier, Staff, int>(
  StaffNotifier.new,
);

final staffRelationsProvider = AsyncNotifierProvider.autoDispose
    .family<StaffRelationsNotifier, StaffRelations, int>(
  StaffRelationsNotifier.new,
);

class StaffNotifier extends AutoDisposeFamilyAsyncNotifier<Staff, int> {
  @override
  FutureOr<Staff> build(arg) async {
    final data = await ref.read(repositoryProvider).request(
      GqlQuery.staff,
      {'id': arg, 'withInfo': true},
    );

    final personNaming = await ref.watch(
      settingsProvider.selectAsync((settings) => settings.personNaming),
    );

    return Staff(data['Staff'], personNaming);
  }

  Future<Object?> toggleFavorite() {
    return ref.read(repositoryProvider).request(
      GqlMutation.toggleFavorite,
      {'staff': arg},
    ).getErrorOrNull();
  }
}

class StaffRelationsNotifier
    extends AutoDisposeFamilyAsyncNotifier<StaffRelations, int> {
  late StaffFilter filter;

  @override
  FutureOr<StaffRelations> build(arg) async {
    filter = ref.watch(staffFilterProvider(arg));
    return await _fetch(const StaffRelations(), null);
  }

  Future<void> fetch(bool onCharacters) async {
    final oldState = state.valueOrNull ?? const StaffRelations();
    if (onCharacters) {
      if (!oldState.charactersAndMedia.hasNext) return;
    } else {
      if (!oldState.roles.hasNext) return;
    }
    state = await AsyncValue.guard(() => _fetch(oldState, onCharacters));
  }

  Future<StaffRelations> _fetch(
    StaffRelations oldState,
    bool? onCharacters,
  ) async {
    final variables = {
      'id': arg,
      'onList': filter.inLists,
      'sort': filter.sort.value,
      if (filter.ofAnime != null) 'type': filter.ofAnime! ? 'ANIME' : 'MANGA',
    };

    if (onCharacters == null) {
      variables['withCharacters'] = true;
      variables['withRoles'] = true;
    } else if (onCharacters) {
      variables['withCharacters'] = true;
      variables['page'] = oldState.charactersAndMedia.next;
    } else {
      variables['withRoles'] = true;
      variables['page'] = oldState.roles.next;
    }

    var data = await ref.read(repositoryProvider).request(
          GqlQuery.staff,
          variables,
        );
    data = data['Staff'];

    var charactersAndMedia = oldState.charactersAndMedia;
    var roles = oldState.roles;

    if (onCharacters == null || onCharacters) {
      final map = data['characterMedia'];
      final items = <(Relation, Relation)>[];
      for (final m in map['edges']) {
        final media = Relation(
          id: m['node']['id'],
          title: m['node']['title']['userPreferred'],
          imageUrl: m['node']['coverImage'][Persistence().imageQuality.value],
          subtitle:
              StringExtension.tryNoScreamingSnakeCase(m['node']['format']),
          type: m['node']['type'] == 'ANIME'
              ? DiscoverType.anime
              : DiscoverType.manga,
        );

        for (final c in m['characters']) {
          if (c == null) continue;

          items.add((
            Relation(
              id: c['id'],
              title: c['name']['userPreferred'],
              imageUrl: c['image']['large'],
              type: DiscoverType.character,
              subtitle: StringExtension.tryNoScreamingSnakeCase(
                m['characterRole'],
              ),
            ),
            media,
          ));
        }
      }

      charactersAndMedia = charactersAndMedia.withNext(
        items,
        map['pageInfo']['hasNextPage'] ?? false,
      );
    }

    if (onCharacters == null || !onCharacters) {
      final map = data['staffMedia'];
      final items = <Relation>[];
      for (final s in map['edges']) {
        items.add(Relation(
          id: s['node']['id'],
          title: s['node']['title']['userPreferred'],
          imageUrl: s['node']['coverImage'][Persistence().imageQuality.value],
          subtitle: s['staffRole'],
          type: s['node']['type'] == 'ANIME'
              ? DiscoverType.anime
              : DiscoverType.manga,
        ));
      }

      roles = roles.withNext(
        items,
        map['pageInfo']['hasNextPage'] ?? false,
      );
    }

    return StaffRelations(charactersAndMedia: charactersAndMedia, roles: roles);
  }
}
