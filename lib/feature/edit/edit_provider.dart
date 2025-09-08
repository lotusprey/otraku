import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/extension/future_extension.dart';
import 'package:otraku/feature/collection/collection_provider.dart';
import 'package:otraku/feature/edit/edit_model.dart';
import 'package:otraku/feature/media/media_provider.dart';
import 'package:otraku/feature/settings/settings_provider.dart';
import 'package:otraku/feature/viewer/persistence_provider.dart';
import 'package:otraku/feature/viewer/repository_provider.dart';
import 'package:otraku/util/graphql.dart';

final entryEditProvider =
    AsyncNotifierProvider.autoDispose.family<EntryEditNotifier, EntryEdit, EditTag>(
  EntryEditNotifier.new,
);

class EntryEditNotifier extends AutoDisposeFamilyAsyncNotifier<EntryEdit, EditTag> {
  @override
  FutureOr<EntryEdit> build(arg) async {
    if (ref.exists(mediaProvider(arg.id))) {
      return ref.watch(mediaProvider(arg.id).selectAsync((s) => s.entryEdit));
    }

    final data = await ref.watch(repositoryProvider).request(GqlQuery.entry, {'mediaId': arg.id});

    final settings = await ref.watch(
      settingsProvider.selectAsync((settings) => settings),
    );

    return EntryEdit(data['Media'], settings, arg.setComplete);
  }

  void updateBy(EntryEdit Function(EntryEdit) callback) => state = switch (state) {
        AsyncData(:final value) => AsyncData(callback(value)),
        _ => state,
      };

  Future<Object?> save() async {
    final value = state.valueOrNull;
    if (value == null) return null;

    state = const AsyncLoading();

    final err = await ref
        .read(repositoryProvider)
        .request(GqlMutation.updateEntry, value.toGraphQlVariables())
        .getErrorOrNull();

    if (err != null) {
      state = AsyncData(value);
      return err;
    }

    final viewerId = ref.read(viewerIdProvider);
    if (viewerId == null) return null;

    final tag = (userId: viewerId, ofAnime: value.baseEntry.isAnime);
    ref
        .read(collectionProvider(tag).notifier)
        .saveEntry(value.baseEntry.mediaId, value.baseEntry.listStatus);

    return null;
  }

  Future<Object?> remove() async {
    final value = state.valueOrNull;
    if (value == null || value.baseEntry.entryId == null) return null;

    state = const AsyncLoading();

    final err = await ref.read(repositoryProvider).request(
      GqlMutation.removeEntry,
      {'entryId': value.baseEntry.entryId},
    ).getErrorOrNull();

    if (err != null) {
      state = AsyncData(value);
      return err;
    }

    final viewerId = ref.read(viewerIdProvider);
    if (viewerId == null) return null;

    final tag = (userId: viewerId, ofAnime: value.baseEntry.isAnime);
    ref.read(collectionProvider(tag).notifier).removeEntry(value.baseEntry.mediaId);

    return null;
  }
}
