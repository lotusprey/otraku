import 'package:get/get.dart';
import 'package:otraku/controllers/collection.dart';
import 'package:otraku/helpers/network.dart';
import 'package:otraku/models/anilist/media_entry_data.dart';

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

  MediaEntryData _entry;
  MediaEntryData _copy;

  MediaEntryData get data => _entry;

  MediaEntryData get oldData => _copy;

  Future<void> fetchEntry(int id) async {
    final body = await Network.request(_entryQuery, {'id': id});

    if (body == null) return;

    _entry = MediaEntryData(body['Media']);
    _copy = MediaEntryData(body['Media']);

    if (_entry.customLists == null) {
      final customLists = Map.fromIterable(
        Get.find<Collection>(
          tag: _entry.type == 'ANIME' ? Collection.ANIME : Collection.MANGA,
        ).customListNames,
        key: (k) => k.toString(),
        value: (_) => false,
      );

      _entry.customLists = customLists;
      _copy.customLists = {...customLists};
    }

    update();
  }
}
