import 'package:otraku/models/settings_model.dart';
import 'package:otraku/utils/client.dart';
import 'package:otraku/utils/graphql.dart';
import 'package:otraku/utils/settings.dart';
import 'package:otraku/utils/scrolling_controller.dart';

class HomeController extends ScrollingController {
  // GetBuilder ids.
  static const ID_HOME = 0;
  static const ID_SETTINGS = 1;
  static const ID_NOTIFICATIONS = 2;

  SettingsModel? _siteSettings;
  late int _homeTab;
  int _notificationCount = 0;
  late bool _onFeed = Settings().inboxOnFeed;

  SettingsModel? get siteSettings => _siteSettings;

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

  int get notificationCount => _notificationCount;

  void nullifyUnread() {
    _notificationCount = 0;
    update([ID_NOTIFICATIONS]);
  }

  Future<void> _fetch() async {
    final data = await Client.request(GqlQuery.settings);
    if (data == null) return;

    _siteSettings = SettingsModel(data['Viewer']);
    _notificationCount = data['Viewer']['unreadNotificationCount'] ?? 0;
    update([ID_SETTINGS, ID_NOTIFICATIONS]);
  }

  Future<bool> updateSettings(Map<String, dynamic> variables) async {
    final data = await Client.request(GqlMutation.updateSettings, variables);
    if (data == null) return false;
    _siteSettings = SettingsModel(data['UpdateUser']);
    return true;
  }

  @override
  void onInit() {
    super.onInit();
    _homeTab = Settings().defaultHomeTab;
    if (_siteSettings == null) _fetch();
  }
}
