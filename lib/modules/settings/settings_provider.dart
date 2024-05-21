import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/modules/viewer/api.dart';
import 'package:otraku/common/utils/graphql.dart';
import 'package:otraku/common/utils/options.dart';
import 'package:otraku/modules/collection/collection_provider.dart';
import 'package:otraku/modules/settings/settings_model.dart';

final settingsProvider =
    AsyncNotifierProvider.autoDispose<SettingsNotifier, Settings>(
  SettingsNotifier.new,
);

class SettingsNotifier extends AutoDisposeAsyncNotifier<Settings> {
  @override
  FutureOr<Settings> build() async {
    final data = await Api.get(GqlQuery.settings);
    return Settings(data['Viewer']);
  }

  /// Update settings and if necessary
  /// restart collections to reflect the changes.
  Future<void> updateSettings(Settings other) async {
    final prev = state.valueOrNull;
    state = await AsyncValue.guard(() async {
      final data = await Api.get(GqlMutation.updateSettings, other.toMap());
      return Settings(data['UpdateUser']);
    });
    final next = state.valueOrNull;
    if (prev == null || next == null) return;

    final id = Persistence().id!;
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
      ref.invalidate(collectionProvider((userId: id, ofAnime: true)));
    }

    if (invalidateMangaCollection) {
      ref.invalidate(collectionProvider((userId: id, ofAnime: false)));
    }
  }

  Future<void> refetchUnread() async {
    try {
      final data = await Api.get(GqlQuery.settings, {'withData': false});
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
