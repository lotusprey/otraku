import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:otraku/controllers/collection.dart';
import 'package:otraku/controllers/explorer.dart';
import 'package:otraku/controllers/user.dart';
import 'package:otraku/controllers/viewer.dart';
import 'package:otraku/helpers/network.dart';
import 'package:otraku/pages/auth_page.dart';
import 'package:otraku/controllers/config.dart';
import 'package:otraku/pages/home/home_page.dart';

Future<void> main() async {
  await GetStorage.init();
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Config.updateTheme();
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Otraku',
      defaultTransition: Platform.isIOS || Platform.isMacOS
          ? Transition.native
          : Transition.downToUp,
      initialRoute: AuthPage.ROUTE,
      getPages: [
        GetPage(name: AuthPage.ROUTE, page: () => AuthPage()),
        GetPage(
          name: HomePage.ROUTE,
          page: () => HomePage(),
          binding: BindingsBuilder(() {
            Get.put(Config());
            Get.put(Collection(null, true), tag: Collection.ANIME).fetch();
            Get.put(Collection(null, false), tag: Collection.MANGA).fetch();
            Get.put(User(), tag: Network.viewerId.toString()).fetchUser(null);
            Get.put(Explorer()).fetchInitial();
            Get.put(Viewer()).fetchData();
          }),
        ),
      ],
    );
  }
}
