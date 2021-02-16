import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:otraku/controllers/collection.dart';
import 'package:otraku/controllers/explorer.dart';
import 'package:otraku/controllers/notifications.dart';
import 'package:otraku/controllers/settings.dart';
import 'package:otraku/controllers/user.dart';
import 'package:otraku/controllers/viewer.dart';
import 'package:otraku/helpers/graph_ql.dart';
import 'package:otraku/pages/auth_page.dart';
import 'package:otraku/controllers/config.dart';
import 'package:otraku/pages/home/home_page.dart';
import 'package:otraku/pages/pushable/notifications_page.dart';
import 'package:otraku/pages/settings/settings_page.dart';

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
        // TODO: Send data to named routes via 'arguments' or 'parameters'
        GetPage(name: AuthPage.ROUTE, page: () => AuthPage()),
        GetPage(
          name: HomePage.ROUTE,
          page: () => HomePage(),
          binding: BindingsBuilder(() {
            Get.parameters;
            Get.arguments;
            Get.put(Config());
            Get.put(Collection(null, true), tag: Collection.ANIME).fetch();
            Get.put(Collection(null, false), tag: Collection.MANGA).fetch();
            Get.put(User(), tag: GraphQL.viewerId.toString()).fetchUser(null);
            Get.put(Explorer()).fetchInitial();
            Get.put(Viewer()).fetchData();
          }),
        ),
        GetPage(
          name: NotificationsPage.ROUTE,
          page: () => NotificationsPage(),
          binding: BindingsBuilder.put(() => Notifications()..fetchData()),
        ),
        GetPage(
          name: SettingsPage.ROUTE,
          page: () => SettingsPage(),
          binding: BindingsBuilder.put(() => Settings()),
        ),
      ],
    );
  }
}
