import 'package:get/get.dart';
import 'package:otraku/controllers/collection_controller.dart';
import 'package:otraku/utils/client.dart';
import 'package:otraku/models/entry_model.dart';
import 'package:otraku/utils/graphql.dart';

class EntryController extends GetxController {
  static const MAIN_ID = 0;
  static const STATUS_ID = 1;
  static const PROGRESS_ID = 2;
  static const SCORE_ID = 3;
  static const START_DATE_ID = 4;
  static const COMPLETE_DATE_ID = 5;

  EntryController(this._id, this._model);

  final int _id;
  EntryModel? _model;
  EntryModel? _copy;

  EntryModel? get model => _copy;
  EntryModel? get oldModel => _model;

  Future<void> _fetch() async {
    final body =
        await Client.request(GqlQuery.media, {'id': _id, 'withMain': true});
    if (body == null) return;
    _model = EntryModel(body['Media']);

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
    if (_model == null) _fetch();
  }
}
