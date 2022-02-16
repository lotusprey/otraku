import 'package:get/get.dart';
import 'package:otraku/utils/client.dart';
import 'package:otraku/models/edit_model.dart';
import 'package:otraku/utils/graphql.dart';

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
