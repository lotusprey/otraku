import 'package:otraku/utils/settings.dart';
import 'package:otraku/utils/scrolling_controller.dart';

class HomeController extends ScrollingController {
  // GetBuilder ids.
  static const ID_HOME = 0;
  static const ID_SETTINGS = 1;
  static const ID_NOTIFICATIONS = 2;

  late int _homeTab;
  late bool _onFeed = Settings().inboxOnFeed;

  bool get onFeed => _onFeed;
  set onFeed(bool v) {
    _onFeed = v;
    Settings().inboxOnFeed = v;
    update([ID_HOME]);
  }

  int get homeTab => _homeTab;
  set homeTab(int v) {
    _homeTab = v;
    update([ID_HOME]);
  }

  @override
  void onInit() {
    super.onInit();
    _homeTab = Settings().defaultHomeTab;
  }
}
