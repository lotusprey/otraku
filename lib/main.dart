import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:otraku/enums/theme_enum.dart';
import 'package:otraku/pages/load_app_page.dart';
import 'package:otraku/controllers/app_config.dart';
import 'package:otraku/controllers/collections.dart';
import 'package:otraku/controllers/explorable.dart';
import 'package:otraku/controllers/users.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  runApp(Otraku());
}

class Otraku extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Get.put(Explorable());
    Get.put(Users());

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<Collections>(
          create: (_) => Collections(),
        ),
      ],
      child: const App(),
    );
  }
}

class App extends StatelessWidget {
  const App({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeIndex = GetStorage().read(AppConfig.THEME) ?? 0;

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Otraku',
      theme: Themes.values[themeIndex].themeData,
      home: LoadAppPage(),
    );
  }
}
