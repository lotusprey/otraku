import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:otraku/pages/loading_page.dart';
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

    Config.updateTheme();

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Otraku',
      home: LoadingPage(),
    );
  }
}
