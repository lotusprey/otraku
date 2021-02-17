import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:otraku/controllers/character.dart';
import 'package:otraku/controllers/collection.dart';
import 'package:otraku/controllers/entry.dart';
import 'package:otraku/controllers/explorer.dart';
import 'package:otraku/controllers/media.dart';
import 'package:otraku/controllers/notifications.dart';
import 'package:otraku/controllers/review.dart';
import 'package:otraku/controllers/settings.dart';
import 'package:otraku/controllers/staff.dart';
import 'package:otraku/controllers/studio.dart';
import 'package:otraku/controllers/user.dart';
import 'package:otraku/controllers/viewer.dart';
import 'package:otraku/helpers/graph_ql.dart';
import 'package:otraku/pages/auth_page.dart';
import 'package:otraku/controllers/config.dart';
import 'package:otraku/pages/home/collection_tab.dart';
import 'package:otraku/pages/home/home_page.dart';
import 'package:otraku/pages/home/user_tab.dart';
import 'package:otraku/pages/media/media_page.dart';
import 'package:otraku/pages/pushable/character_page.dart';
import 'package:otraku/pages/pushable/edit_entry_page.dart';
import 'package:otraku/pages/pushable/filter_page.dart';
import 'package:otraku/pages/pushable/notifications_page.dart';
import 'package:otraku/pages/pushable/review_page.dart';
import 'package:otraku/pages/pushable/staff_page.dart';
import 'package:otraku/pages/pushable/studio_page.dart';
import 'package:otraku/pages/pushable/tab_page.dart';
import 'package:otraku/pages/settings/settings_page.dart';
import 'package:otraku/tools/navigation/custom_drawer.dart';

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
            Get.put(Collection(null, true), tag: Collection.ANIME);
            Get.put(Collection(null, false), tag: Collection.MANGA);
            Get.put(User(GraphQL.viewerId), tag: GraphQL.viewerId.toString());
            Get.put(Explorer());
            Get.put(Viewer());
          }),
        ),
        GetPage(
          name: UserTab.ROUTE,
          page: () => TabPage(UserTab(Get.arguments[0], Get.arguments[1])),
          binding: BindingsBuilder(() {
            if (!Get.isRegistered<User>(tag: Get.arguments[0].toString()))
              Get.put(User(Get.arguments[0]), tag: Get.arguments[0].toString());
          }),
        ),
        GetPage(
          name: CollectionTab.ROUTE,
          page: () => TabPage(
            CollectionTab(
              otherUserId: Get.arguments[0],
              ofAnime: Get.arguments[1],
              collectionTag: Get.arguments[2],
              key: null,
            ),
            drawer: CollectionDrawer(Get.arguments[2]),
          ),
          binding: BindingsBuilder(() {
            if (!Get.isRegistered<Collection>(tag: Get.arguments[2]))
              Get.put(
                Collection(Get.arguments[0], Get.arguments[1]),
                tag: Get.arguments[2],
              );
          }),
        ),
        GetPage(
          name: MediaPage.ROUTE,
          page: () => MediaPage(Get.arguments[0], Get.arguments[1]),
          binding: BindingsBuilder(() {
            if (!Get.isRegistered<Media>(tag: Get.arguments[0].toString()))
              Get.put(Media(Get.arguments[0]),
                  tag: Get.arguments[0].toString());
          }),
        ),
        GetPage(
          name: CharacterPage.ROUTE,
          page: () => CharacterPage(Get.arguments[0], Get.arguments[1]),
          binding: BindingsBuilder(() {
            if (!Get.isRegistered<Character>(tag: Get.arguments[0].toString()))
              Get.put(Character(Get.arguments[0]),
                  tag: Get.arguments[0].toString());
          }),
        ),
        GetPage(
          name: StaffPage.ROUTE,
          page: () => StaffPage(Get.arguments[0], Get.arguments[1]),
          binding: BindingsBuilder(() {
            if (!Get.isRegistered<Staff>(tag: Get.arguments[0].toString()))
              Get.put(Staff(Get.arguments[0]),
                  tag: Get.arguments[0].toString());
          }),
        ),
        GetPage(
          name: StudioPage.ROUTE,
          page: () => StudioPage(Get.arguments[0], Get.arguments[1]),
          binding: BindingsBuilder(() {
            if (!Get.isRegistered<Studio>(tag: Get.arguments[0].toString()))
              Get.put(Studio(Get.arguments[0]),
                  tag: Get.arguments[0].toString());
          }),
        ),
        GetPage(
          name: ReviewPage.ROUTE,
          page: () => ReviewPage(Get.arguments[0], Get.arguments[1]),
          binding: BindingsBuilder(() {
            if (!Get.isRegistered<Review>(tag: Get.arguments[0].toString()))
              Get.put(Review(Get.arguments[0]),
                  tag: Get.arguments[0].toString());
          }),
        ),
        GetPage(
          name: NotificationsPage.ROUTE,
          page: () => NotificationsPage(),
          binding: BindingsBuilder.put(() => Notifications()),
        ),
        GetPage(
          name: EditEntryPage.ROUTE,
          page: () => EditEntryPage(Get.arguments[0], Get.arguments[1]),
          binding: BindingsBuilder.put(() => Entry(Get.arguments[0])),
        ),
        GetPage(
          name: FilterPage.ROUTE,
          page: () => FilterPage(Get.arguments[0], Get.arguments[1]),
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
