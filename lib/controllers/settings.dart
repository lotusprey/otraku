import 'package:get/get.dart';
import 'package:otraku/controllers/collection.dart';
import 'package:otraku/controllers/explorer.dart';
import 'package:otraku/controllers/viewer.dart';
import 'package:otraku/models/settings_model.dart';
import 'package:otraku/utils/filterable.dart';

class Settings extends GetxController {
  final changes = <String, dynamic>{};
  SettingsModel? _model;
  int _pageIndex = 0;

  SettingsModel? get model => _model;

  int get pageIndex => _pageIndex;

  set pageIndex(int val) {
    _pageIndex = val;
    update();
  }

  @override
  void onInit() {
    super.onInit();
    _model = Get.find<Viewer>().settings;
  }

  @override
  void onClose() async {
    if (changes.length > 0) {
      final ok = await Get.find<Viewer>().updateSettings(changes);
      if (ok) {
        if (changes.containsKey('displayAdultContent')) {
          if (changes['displayAdultContent'])
            Get.find<Explorer>().setFilterWithKey(Filterable.IS_ADULT);
          else
            Get.find<Explorer>()
                .setFilterWithKey(Filterable.IS_ADULT, value: false);
        }

        if (changes.containsKey('scoreFormat') ||
            changes.containsKey('titleLanguage')) {
          Get.find<Collection>(tag: Collection.ANIME).fetch();
          Get.find<Collection>(tag: Collection.MANGA).fetch();
        } else {
          if (changes.containsKey('splitCompletedAnime'))
            Get.find<Collection>(tag: Collection.ANIME).fetch();

          if (changes.containsKey('splitCompletedManga'))
            Get.find<Collection>(tag: Collection.MANGA).fetch();
        }
      }
    }
    super.onClose();
  }
}
