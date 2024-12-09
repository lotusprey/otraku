import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/feature/viewer/persistence_provider.dart';
import 'package:otraku/feature/viewer/repository_provider.dart';
import 'package:otraku/util/graphql.dart';
import 'package:otraku/feature/collection/collection_provider.dart';
import 'package:otraku/feature/settings/settings_model.dart';

final settingsProvider =
    AsyncNotifierProvider.autoDispose<SettingsNotifier, Settings>(
  SettingsNotifier.new,
);

class SettingsNotifier extends AutoDisposeAsyncNotifier<Settings> {
  @override
  FutureOr<Settings> build() async {
    final viewerId = ref.watch(viewerIdProvider);
    if (viewerId == null) return Settings.empty();

    final data = await ref.read(repositoryProvider).request(GqlQuery.settings);
    return Settings(data['Viewer']);
  }

  /// Update settings and if necessary
  /// restart collections to reflect the changes.
  Future<void> updateSettings(Settings other) async {
    final viewerId = ref.watch(viewerIdProvider);
    if (viewerId == null) return;

    final prev = state.valueOrNull;
    state = await AsyncValue.guard(() async {
      final data = await ref
          .read(repositoryProvider)
          .request(GqlMutation.updateSettings, other.toMap());
      return Settings(data['UpdateUser']);
    });
    final next = state.valueOrNull;
    if (prev == null || next == null) return;

    bool invalidateAnimeCollection = false;
    bool invalidateMangaCollection = false;

    if (prev.scoreFormat != next.scoreFormat ||
        prev.titleLanguage != next.titleLanguage) {
      invalidateAnimeCollection = true;
      invalidateMangaCollection = true;
    } else {
      if (prev.splitCompletedAnime != next.splitCompletedAnime) {
        invalidateAnimeCollection = true;
      }
      if (prev.splitCompletedManga != next.splitCompletedManga) {
        invalidateMangaCollection = true;
      }
    }

    if (invalidateAnimeCollection) {
      ref.invalidate(collectionProvider((userId: viewerId, ofAnime: true)));
    }

    if (invalidateMangaCollection) {
      ref.invalidate(collectionProvider((userId: viewerId, ofAnime: false)));
    }
  }

  Future<void> refetchUnread() async {
    try {
      final data = await ref
          .read(repositoryProvider)
          .request(GqlQuery.settings, {'withData': false});
      state = state.whenData(
        (v) => v.copy(
          unreadNotifications: data['Viewer']['unreadNotificationCount'] ?? 0,
        ),
      );
    } catch (_) {}
  }

  void clearUnread() =>
      state = state.whenData((v) => v.copy(unreadNotifications: 0));
}
