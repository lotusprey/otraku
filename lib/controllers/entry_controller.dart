import 'package:get/get.dart';
import 'package:otraku/controllers/collection_controller.dart';
import 'package:otraku/utils/client.dart';
import 'package:otraku/models/entry_model.dart';

class EntryController extends GetxController {
  // ***************************************************************************
  // CONSTANTS
  // ***************************************************************************

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

  static const MAIN_ID = 0;
  static const STATUS_ID = 1;
  static const PROGRESS_ID = 2;
  static const SCORE_ID = 3;
  static const START_DATE_ID = 4;
  static const COMPLETE_DATE_ID = 5;

  // ***************************************************************************
  // DATA
  // ***************************************************************************

  final int _id;
  EntryController(this._id, [this._model]);

  EntryModel? _model;
  EntryModel? _copy;

  EntryModel? get model => _copy;
  EntryModel? get oldModel => _model;

  // ***************************************************************************
  // FETCHING
  // ***************************************************************************

  Future<void> fetch() async {
    if (_model == null) {
      final body = await Client.request(_entryQuery, {'id': _id});
      if (body == null) return;
      _model = EntryModel(body['Media']);
    }

    if (_model!.customLists.isEmpty) {
      final customLists = Map.fromIterable(
        Get.find<CollectionController>(
          tag: _model!.type == 'ANIME'
              ? CollectionController.ANIME
              : CollectionController.MANGA,
        ).customListNames,
        key: (k) => k.toString(),
        value: (_) => false,
      );

      _model!.customLists = customLists;
    }
    _copy = EntryModel.copy(_model!);

    update([MAIN_ID]);
  }

  @override
  void onInit() {
    super.onInit();
    fetch();
  }
}
