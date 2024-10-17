import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/extension/future_extension.dart';
import 'package:otraku/extension/string_extension.dart';
import 'package:otraku/feature/staff/staff_filter_model.dart';
import 'package:otraku/feature/settings/settings_provider.dart';
import 'package:otraku/feature/staff/staff_filter_provider.dart';
import 'package:otraku/feature/staff/staff_model.dart';
import 'package:otraku/feature/viewer/persistence_provider.dart';
import 'package:otraku/feature/viewer/repository_provider.dart';
import 'package:otraku/util/graphql.dart';

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

    final imageQuality = ref.read(persistenceProvider).options.imageQuality;

    var charactersAndMedia = oldState.charactersAndMedia;
    var roles = oldState.roles;

    if (onCharacters == null || onCharacters) {
      final map = data['characterMedia'];
      final items = <(StaffRelatedItem, StaffRelatedItem)>[];
      for (final m in map['edges']) {
        final media = StaffRelatedItem.media(
          m['node'],
          StringExtension.tryNoScreamingSnakeCase(m['node']['format']),
          imageQuality,
        );

        for (final c in m['characters']) {
          if (c == null) continue;

          items.add((
            StaffRelatedItem.character(
              c,
              StringExtension.tryNoScreamingSnakeCase(m['characterRole']),
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
      final items = <StaffRelatedItem>[];
      for (final s in map['edges']) {
        items.add(StaffRelatedItem.media(
          s['node'],
          s['staffRole'],
          imageQuality,
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
