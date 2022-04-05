import 'package:get/get.dart';
import 'package:otraku/constants/list_status.dart';
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

  EditController(this._id, this._oldModel, this._complete);

  final int _id;
  final bool _complete;
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
    _completeEntry(_newModel!);
    update([ID_MAIN]);
  }

  // If needed, set the model as completed media.
  void _completeEntry(EditModel _model) {
    if (!_complete) return;
    _model.status = ListStatus.COMPLETED;
    _model.completedAt = DateTime.now();
    if (_model.progressMax != null) _model.progress = _model.progressMax!;
    if (_model.progressVolumesMax != null)
      _model.progressVolumes = _model.progressVolumesMax!;
  }

  @override
  void onInit() {
    super.onInit();
    if (_oldModel == null)
      _fetch();
    else {
      _completeEntry(_oldModel!);
      _newModel = EditModel.copy(_oldModel!);
    }
  }
}
