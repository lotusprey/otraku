import 'package:get/get.dart';
import 'package:otraku/models/settings_model.dart';
import 'package:otraku/utils/client.dart';
import 'package:otraku/utils/graphql.dart';
import 'package:otraku/utils/local_settings.dart';

class HomeController extends GetxController {
  // GetBuilder ids.
  static const ID_HOME = 0;
  static const ID_SETTINGS = 1;
  static const ID_NOTIFICATIONS = 2;

  SettingsModel? _siteSettings;
  late int _homeTab;
  int _settingsTab = 0;

  SettingsModel? get siteSettings => _siteSettings;

  int get homeTab => _homeTab;
  set homeTab(int v) {
    _homeTab = v;
    update([ID_HOME]);
  }

  int get settingsTab => _settingsTab;
  set settingsTab(int v) {
    _settingsTab = v;
    update([ID_SETTINGS]);
  }

  void nullifyUnread() {
    LocalSettings().notificationCount = 0;
    update([ID_NOTIFICATIONS]);
  }

  Future<void> _fetch() async {
    final data = await Client.request(GqlQuery.settings);
    if (data == null) return;

    _siteSettings = SettingsModel(data['Viewer']);
    LocalSettings().notificationCount =
        data['Viewer']['unreadNotificationCount'] ?? 0;
    update([ID_SETTINGS]);
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
    _homeTab = LocalSettings().defaultHomeTab;
    if (_siteSettings == null) _fetch();
  }
}
