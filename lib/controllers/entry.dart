import 'package:get/get.dart';
import 'package:otraku/controllers/collection.dart';
import 'package:otraku/models/tuple.dart';
import 'package:otraku/services/graph_ql.dart';
import 'package:otraku/models/page_data/entry_data.dart';

class Entry extends GetxController {
  static const _entryQuery = r'''
    query ItemUserData($id: Int) {
      Media(id: $id) {
        id
        type
        episodes
        chapters
        volumes
        mediaListEntry {
          id
          status
          progress
          progressVolumes
          score
          repeat
          notes
          startedAt {year month day}
          completedAt {year month day}
          private
          hiddenFromStatusLists
          customLists
        }
      }
    }
  ''';

  EntryData _entry;
  EntryData _copy;

  EntryData get data => _entry;

  EntryData get oldData => _copy;

  Future<void> fetchEntry(int id) async {
    final body = await GraphQl.request(_entryQuery, {'id': id});

    if (body == null) return;

    _entry = EntryData(body['Media']);
    _copy = EntryData(body['Media']);

    if (_entry.customLists == null) {
      final customLists = Get.find<Collection>(
        tag: _entry.type == 'ANIME' ? Collection.ANIME : Collection.MANGA,
      ).customListNames.map((e) => Tuple(e, false)).toList();

      _entry.customLists = customLists;
      _copy.customLists = [...customLists];
    }

    update();
  }
}
