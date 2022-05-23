import 'package:get/get.dart';
import 'package:otraku/models/tag_group_model.dart';
import 'package:otraku/utils/api.dart';

class TagGroupController extends GetxController {
  TagGroupModel? _model;

  TagGroupModel? get model => _model;

  Future<void> _fetch() async {
    const query = '''
        query Filters {
          GenreCollection
          MediaTagCollection {id name description category isGeneralSpoiler}
        }
      ''';

    final data = await Api.request(query);
    if (data == null) return;
    _model = TagGroupModel(data);
    update();
  }

  @override
  void onInit() {
    super.onInit();
    if (_model == null) _fetch();
  }
}
