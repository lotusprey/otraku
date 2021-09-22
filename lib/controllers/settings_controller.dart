import 'package:get/get.dart';
import 'package:otraku/controllers/collection_controller.dart';
import 'package:otraku/controllers/explore_controller.dart';
import 'package:otraku/controllers/viewer_controller.dart';
import 'package:otraku/models/settings_model.dart';
import 'package:otraku/utils/filterable.dart';

class SettingsController extends GetxController {
  static const ADVANCED_SCORES_ID = 0;

  final changes = <String, dynamic>{};
  late SettingsModel _model;
  int _pageIndex = 0;

  SettingsModel get model => _model;

  int get pageIndex => _pageIndex;
  set pageIndex(int val) {
    _pageIndex = val;
    update();
  }

  @override
  void onInit() {
    super.onInit();
    _model = Get.find<ViewerController>().settings!;
  }

  @override
  void onClose() async {
    if (changes.length > 0 &&
        await Get.find<ViewerController>().updateSettings(changes)) {
      if (changes.containsKey('displayAdultContent')) {
        if (changes['displayAdultContent'])
          Get.find<ExploreController>().setFilterWithKey(Filterable.IS_ADULT);
        else
          Get.find<ExploreController>()
              .setFilterWithKey(Filterable.IS_ADULT, value: false);
      }

      if (changes.containsKey('scoreFormat') ||
          changes.containsKey('titleLanguage')) {
        Get.find<CollectionController>(tag: CollectionController.ANIME).fetch();
        Get.find<CollectionController>(tag: CollectionController.MANGA).fetch();
      } else {
        if (changes.containsKey('splitCompletedAnime'))
          Get.find<CollectionController>(tag: CollectionController.ANIME)
              .fetch();

        if (changes.containsKey('splitCompletedManga'))
          Get.find<CollectionController>(tag: CollectionController.MANGA)
              .fetch();
      }
    }
    super.onClose();
  }
}
