import 'package:get/get.dart';
import 'package:otraku/controllers/collection_controller.dart';
import 'package:otraku/utils/client.dart';
import 'package:otraku/models/edit_model.dart';
import 'package:otraku/utils/graphql.dart';
import 'package:otraku/utils/settings.dart';

class EditController extends GetxController {
  static const ID_MAIN = 0;
  static const ID_STATUS = 1;
  static const ID_PROGRESS = 2;
  static const ID_SCORE = 3;
  static const ID_START_DATE = 4;
  static const ID_COMPLETE_DATE = 5;

  EditController(this._id, this._oldModel);

  final int _id;
  EditModel? _oldModel;
  EditModel? _newModel;

  EditModel? get model => _newModel;
  EditModel? get oldModel => _oldModel;

  Future<void> _fetch() async {
    final data = await Client.request(GqlQuery.media, {
      'id': _id,
      'withMain': true,
    });
    if (data == null) return;

    _oldModel = EditModel(data['Media']);

    // TODO custom lists not showing in media page
    if (_oldModel!.customLists.isEmpty)
      _oldModel!.customLists = Map.fromIterable(
        Get.find<CollectionController>(
          tag: _oldModel!.type == 'ANIME'
              ? '${Settings().id}true'
              : '${Settings().id}false',
        ).customListNames,
        value: (_) => false,
      );

    _newModel = EditModel.copy(_oldModel!);
    update([ID_MAIN]);
  }

  @override
  void onInit() {
    super.onInit();
    if (_oldModel == null)
      _fetch();
    else
      _newModel = EditModel.copy(_oldModel!);
  }
}
