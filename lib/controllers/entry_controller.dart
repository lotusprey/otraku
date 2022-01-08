import 'package:get/get.dart';
import 'package:otraku/controllers/collection_controller.dart';
import 'package:otraku/utils/client.dart';
import 'package:otraku/models/entry_model.dart';
import 'package:otraku/utils/graphql.dart';
import 'package:otraku/utils/settings.dart';

class EntryController extends GetxController {
  static const ID_MAIN = 0;
  static const ID_STATUS = 1;
  static const ID_PROGRESS = 2;
  static const ID_SCORE = 3;
  static const ID_START_DATE = 4;
  static const ID_COMPLETE_DATE = 5;

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
              ? '${Settings().id}true'
              : '${Settings().id}false',
        ).customListNames,
        key: (k) => k.toString(),
        value: (_) => false,
      );

      _model!.customLists = customLists;
    }
    _copy = EntryModel.copy(_model!);

    update([ID_MAIN]);
  }

  @override
  void onInit() {
    super.onInit();
    if (_model == null)
      _fetch();
    else
      _copy = EntryModel.copy(_model!);
  }
}
