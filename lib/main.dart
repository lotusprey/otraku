import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:otraku/enums/theme_enum.dart';
import 'package:otraku/pages/load_app_page.dart';
import 'package:otraku/controllers/config.dart';
import 'package:otraku/controllers/collections.dart';
import 'package:otraku/controllers/explorable.dart';
import 'package:otraku/controllers/users.dart';

Future<void> main() async {
  await GetStorage.init();
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Get.put(Collections());
    Get.put(Explorable());
    Get.put(Users());

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Otraku',
      themeMode: ThemeMode.values[Config.storage.read(Config.THEME_MODE) ?? 0],
      theme:
          Themes.values[Config.storage.read(Config.LIGHT_THEME) ?? 0].themeData,
      darkTheme:
          Themes.values[Config.storage.read(Config.DARK_THEME) ?? 0].themeData,
      home: LoadAppPage(),
    );
  }
}
