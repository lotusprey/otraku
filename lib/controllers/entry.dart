import 'package:get/get.dart';
import 'package:otraku/controllers/collection.dart';
import 'package:otraku/helpers/client.dart';
import 'package:otraku/models/anilist/entry_model.dart';

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

  final int _id;
  Entry(this._id);

  EntryModel _entry;
  EntryModel _copy;

  EntryModel get data => _entry;
  EntryModel get oldData => _copy;

  Future<void> fetch() async {
    final body = await Client.request(_entryQuery, {'id': _id});
    if (body == null) return;

    _entry = EntryModel(body['Media']);
    _copy = EntryModel(body['Media']);

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

  @override
  void onInit() {
    super.onInit();
    fetch();
  }
}
