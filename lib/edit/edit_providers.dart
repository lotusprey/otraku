import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/edit/edit_model.dart';
import 'package:otraku/settings/user_settings.dart';
import 'package:otraku/utils/api.dart';
import 'package:otraku/utils/graphql.dart';

/// Update an entry and return the entry id. This may be useful, if
/// the entry didn't exist up until now, i.e. there wasn't an id.
Future<int?> updateEntry(Edit edit) async {
  try {
    final data = await Api.get(GqlMutation.updateEntry, edit.toMap());
    return data['SaveMediaListEntry']['id'];
  } catch (e) {
    return null;
  }
}

/// Increment entry progress. The entry's custom lists are returned,
/// so that all of them can easily be updated locally.
Future<List<String>?> updateProgress(int mediaId, int progress) async {
  try {
    final data = await Api.get(
      GqlMutation.updateProgress,
      {'mediaId': mediaId, 'progress': progress},
    );

    final customLists = <String>[];
    for (final e in data['SaveMediaListEntry']['customLists'].entries)
      if (e.value) customLists.add(e.key.toString().toLowerCase());
    return customLists;
  } catch (e) {
    return null;
  }
}

/// Remove an entry.
Future<void> removeEntry(int entryId) async {
  try {
    await Api.get(GqlMutation.removeEntry, {'entryId': entryId});
  } catch (e) {}
}

final currentEditProvider = FutureProvider.autoDispose.family<Edit, int>(
  (ref, id) async {
    final data = await Api.get(GqlQuery.media, {'id': id, 'withMain': true});
    return Edit(data['Media'], ref.watch(userSettingsProvider));
  },
);

final editProvider = StateProvider.autoDispose<Edit>((ref) => Edit.temp());
