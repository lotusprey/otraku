import 'package:get/get.dart';
import 'package:otraku/controllers/collection.dart';
import 'package:otraku/utils/client.dart';
import 'package:otraku/models/entry_model.dart';

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
          advancedScores
        }
      }
    }
  ''';

  final int _id;
  Entry(this._id, [this._model]);

  EntryModel? _model;
  EntryModel? _copy;

  EntryModel? get model => _copy;
  EntryModel? get oldModel => _model;

  Future<void> fetch() async {
    if (_model == null) {
      final body = await Client.request(_entryQuery, {'id': _id});
      if (body == null) return;
      _model = EntryModel(body['Media']);
    }

    if (_model!.customLists.isEmpty) {
      final customLists = Map.fromIterable(
        Get.find<Collection>(
          tag: _model!.type == 'ANIME' ? Collection.ANIME : Collection.MANGA,
        ).customListNames,
        key: (k) => k.toString(),
        value: (_) => false,
      );

      _model!.customLists = customLists;
    }
    _copy = EntryModel.copy(_model!);

    update();
  }

  @override
  void onInit() {
    super.onInit();
    fetch();
  }
}
