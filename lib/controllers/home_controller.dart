import 'package:get/get.dart';
import 'package:otraku/utils/client.dart';
import 'package:otraku/models/settings_model.dart';
import 'package:otraku/utils/graphql.dart';

class HomeController extends GetxController {
  // GetBuilder ids.
  static const ID_HOME = 0;
  static const ID_SETTINGS = 1;
  static const ID_NOTIFICATIONS = 2;

  static final localSettings = LocalSettings();

  SettingsSiteModel? _siteSettings;
  late int _homeTab;
  int _settingsTab = 0;

  SettingsSiteModel? get siteSettings => _siteSettings;

  int get homeTab => _homeTab;
  set homeTab(int v) {
    _homeTab = v;
    update([ID_HOME]);
  }

  int get settingsTab => _settingsTab;
  set settingsTab(int v) {
    settingsTab = v;
    update([ID_SETTINGS]);
  }

  void nullifyUnread() {
    localSettings.notificationCount = 0;
    update([ID_NOTIFICATIONS]);
  }

  Future<void> _fetch() async {
    final data = await Client.request(GqlQuery.settings);
    if (data == null) return;

    _siteSettings = SettingsSiteModel(data['Viewer']);
    localSettings.notificationCount =
        data['Viewer']['unreadNotificationCount'] ?? 0;
    update([ID_SETTINGS]);
  }

  Future<bool> updateSettings(Map<String, dynamic> variables) async {
    final data = await Client.request(GqlMutation.updateSettings, variables);
    if (data == null) return false;
    _siteSettings = SettingsSiteModel(data['UpdateUser']);
    return true;
  }

  @override
  void onInit() {
    super.onInit();
    _homeTab = localSettings.defaultHomeTab;
    if (_siteSettings == null) _fetch();
  }
}
