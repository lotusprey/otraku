import 'package:get/get.dart';
import 'package:otraku/utils/client.dart';
import 'package:otraku/utils/config.dart';
import 'package:otraku/models/settings_model.dart';
import 'package:otraku/utils/graphql.dart';

class ViewerController extends GetxController {
  final _unreadCount = 0.obs;
  SettingsModel? _settings;

  SettingsModel? get settings => _settings;
  int get unreadCount => _unreadCount();

  void nullifyUnread() {
    _unreadCount.value = 0;
    Config.storage.write(Config.LAST_NOTIFICATION_COUNT, 0);
  }

  Future<void> _fetch() async {
    final data = await Client.request(GqlQuery.settings);
    if (data == null) return;

    if (_settings == null) _settings = SettingsModel(data['Viewer']);
    _unreadCount.value = data['Viewer']['unreadNotificationCount'] ?? 0;
    Config.storage.write(Config.LAST_NOTIFICATION_COUNT, _unreadCount());
    update();
  }

  Future<bool> updateSettings(Map<String, dynamic> variables) async {
    final data = await Client.request(GqlMutation.updateSettings, variables);
    if (data == null) return false;
    _settings = SettingsModel(data['UpdateUser']);
    return true;
  }

  @override
  void onInit() {
    super.onInit();
    if (_settings == null) _fetch();
  }
}
