import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:otraku/models/collection_legacy.dart';
import 'package:otraku/models/date_time_mapping.dart';
import 'package:otraku/models/page_data/entry_data.dart';
import 'package:otraku/models/sample_data/media_entry.dart';
import 'package:otraku/services/graph_ql.dart';

class Collections extends GetxController {
  static const _updateEntryMutation = '';
  static const _removeEntryMutation = '';
  Collection _myAnime;
  Collection _myManga;

  Future<bool> updateEntry(EntryData original, EntryData changed) async {
    final List<String> newCustomLists =
        changed.customLists.where((t) => t.item2).map((t) => t.item1).toList();

    final data = await GraphQl.request(
      _updateEntryMutation,
      {
        'mediaId': changed.mediaId,
        'entryId': changed.entryId,
        'status': describeEnum(changed.status),
        'progress': changed.progress,
        'progressVolumes': changed.progressVolumes,
        'score': changed.score,
        'repeat': changed.repeat,
        'notes': changed.notes,
        'startedAt': dateTimeToMap(changed.startedAt),
        'completedAt': dateTimeToMap(changed.completedAt),
        'private': changed.private,
        'hiddenFromStatusLists': changed.hiddenFromStatusLists,
        'customLists': newCustomLists,
      },
    );

    if (data == null) return false;

    MediaEntry entry = MediaEntry(data['SaveMediaListEntry']);

    if (changed.type == 'ANIME') {
      _myAnime.updateEntry(original, changed, entry, newCustomLists);
    } else {
      _myManga.updateEntry(original, changed, entry, newCustomLists);
    }

    return true;
  }

  Future<bool> removeEntry(EntryData entry) async {
    final data = await GraphQl.request(
      _removeEntryMutation,
      {'entryId': entry.entryId},
      popOnError: false,
    );

    if (data == null || data['DeleteMediaListEntry']['deleted'] == false)
      return false;

    if (entry.type == 'ANIME') {
      _myAnime.removeEntry(entry);
    } else {
      _myManga.removeEntry(entry);
    }

    return true;
  }
}
