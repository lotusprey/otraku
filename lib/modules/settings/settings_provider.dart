import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/common/utils/api.dart';
import 'package:otraku/common/utils/graphql.dart';
import 'package:otraku/common/utils/options.dart';
import 'package:otraku/modules/collection/collection_preview_provider.dart';
import 'package:otraku/modules/collection/collection_providers.dart';
import 'package:otraku/modules/settings/settings_model.dart';

final settingsProvider =
    AsyncNotifierProvider<SettingsNotifier, Settings>(SettingsNotifier.new);

class SettingsNotifier extends AsyncNotifier<Settings> {
  @override
  FutureOr<Settings> build() async {
    final data = await Api.get(GqlQuery.settings);
    return Settings(data['Viewer']);
  }

  /// Update settings and if necessary
  /// restart collections to reflect the changes.
  Future<void> updateWith(Settings other) async {
    final prev = state.valueOrNull;
    state = await AsyncValue.guard(() async {
      final data = await Api.get(GqlMutation.updateSettings, other.toMap());
      return Settings(data['UpdateUser']);
    });
    final next = state.valueOrNull;
    if (prev == null || next == null) return;

    final id = Options().id!;
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
      final tag = (userId: id, ofAnime: true);
      if (ref.exists(collectionProvider(tag))) {
        ref.invalidate(collectionProvider(tag));
      } else {
        ref.invalidate(collectionPreviewProvider(tag));
      }
    }

    if (invalidateMangaCollection) {
      final tag = (userId: id, ofAnime: false);
      if (ref.exists(collectionProvider(tag))) {
        ref.invalidate(collectionProvider(tag));
      } else {
        ref.invalidate(collectionPreviewProvider(tag));
      }
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
