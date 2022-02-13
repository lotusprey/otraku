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

  EditController(this._id, this._currModel);

  final int _id;
  EditModel? _currModel;
  EditModel? _nextModel;

  EditModel? get model => _nextModel;
  EditModel? get currModel => _currModel;

  Future<void> _fetch() async {
    final data = await Client.request(GqlQuery.media, {
      'id': _id,
      'withMain': true,
    });
    if (data == null) return;

    _currModel = EditModel(data['Media']);

    // TODO custom lists not showing in media page
    if (_currModel!.customLists.isEmpty)
      _currModel!.customLists = Map.fromIterable(
        Get.find<CollectionController>(
          tag: _currModel!.type == 'ANIME'
              ? '${Settings().id}true'
              : '${Settings().id}false',
        ).customListNames,
        value: (_) => false,
      );

    _nextModel = EditModel.copy(_currModel!);
    update([ID_MAIN]);
  }

  @override
  void onInit() {
    super.onInit();
    if (_currModel == null)
      _fetch();
    else
      _nextModel = EditModel.copy(_currModel!);
  }
}
