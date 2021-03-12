import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:otraku/controllers/activity.dart';
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
import 'package:otraku/utils/config.dart';
import 'package:otraku/utils/client.dart';
import 'package:otraku/pages/auth_page.dart';
import 'package:otraku/pages/home/collection_page.dart';
import 'package:otraku/pages/home/home_page.dart';
import 'package:otraku/pages/home/user_page.dart';
import 'package:otraku/pages/media/media_page.dart';
import 'package:otraku/pages/pushable/user_activities_page.dart';
import 'package:otraku/pages/pushable/activity_page.dart';
import 'package:otraku/pages/pushable/character_page.dart';
import 'package:otraku/pages/pushable/edit_entry_page.dart';
import 'package:otraku/pages/pushable/favourites_page.dart';
import 'package:otraku/pages/pushable/filter_page.dart';
import 'package:otraku/pages/pushable/notifications_page.dart';
import 'package:otraku/pages/pushable/review_page.dart';
import 'package:otraku/pages/pushable/staff_page.dart';
import 'package:otraku/pages/pushable/studio_page.dart';
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
      defaultTransition: Transition.cupertino,
      initialRoute: AuthPage.ROUTE,
      getPages: [
        GetPage(name: AuthPage.ROUTE, page: () => AuthPage()),
        GetPage(
          name: HomePage.ROUTE,
          page: () => HomePage(),
          binding: BindingsBuilder(() {
            Get.put(Collection(null, true), tag: Collection.ANIME);
            Get.put(Collection(null, false), tag: Collection.MANGA);
            Get.put(User(Client.viewerId), tag: Client.viewerId.toString());
            Get.put(Explorer());
            Get.put(Viewer());
          }),
        ),
        GetPage(
          name: UserPage.ROUTE,
          page: () => UserPage(Get.arguments[0], Get.arguments[1]),
          binding: BindingsBuilder(() {
            if (!Get.isRegistered<User>(tag: Get.arguments[0].toString()))
              Get.put(User(Get.arguments[0]), tag: Get.arguments[0].toString());
          }),
        ),
        GetPage(
          name: CollectionPage.ROUTE,
          page: () => CollectionPage(
            otherUserId: Get.arguments[0],
            ofAnime: Get.arguments[1],
            collectionTag: Get.arguments[2],
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
              Get.put(
                Media(Get.arguments[0]),
                tag: Get.arguments[0].toString(),
              );
          }),
        ),
        GetPage(
          name: CharacterPage.ROUTE,
          page: () => CharacterPage(Get.arguments[0], Get.arguments[1]),
          binding: BindingsBuilder(() {
            if (!Get.isRegistered<Character>(tag: Get.arguments[0].toString()))
              Get.put(
                Character(Get.arguments[0]),
                tag: Get.arguments[0].toString(),
              );
          }),
        ),
        GetPage(
          name: StaffPage.ROUTE,
          page: () => StaffPage(Get.arguments[0], Get.arguments[1]),
          binding: BindingsBuilder(() {
            if (!Get.isRegistered<Staff>(tag: Get.arguments[0].toString()))
              Get.put(
                Staff(Get.arguments[0]),
                tag: Get.arguments[0].toString(),
              );
          }),
        ),
        GetPage(
          name: StudioPage.ROUTE,
          page: () => StudioPage(Get.arguments[0], Get.arguments[1]),
          binding: BindingsBuilder(() {
            if (!Get.isRegistered<Studio>(tag: Get.arguments[0].toString()))
              Get.put(
                Studio(Get.arguments[0]),
                tag: Get.arguments[0].toString(),
              );
          }),
        ),
        GetPage(
          name: ReviewPage.ROUTE,
          page: () => ReviewPage(Get.arguments[0], Get.arguments[1]),
          binding: BindingsBuilder(() {
            if (!Get.isRegistered<Review>(tag: Get.arguments[0].toString()))
              Get.put(
                Review(Get.arguments[0]),
                tag: Get.arguments[0].toString(),
              );
          }),
        ),
        GetPage(
          name: ActivityPage.ROUTE,
          page: () => ActivityPage(Get.arguments[0]),
          binding: BindingsBuilder(() {
            if (!Get.isRegistered<Activity>(tag: Get.arguments[0].toString()))
              Get.put(
                Activity(Get.arguments[0], Get.arguments[1]),
                tag: Get.arguments[0].toString(),
              );
          }),
        ),
        GetPage(
          name: NotificationsPage.ROUTE,
          page: () => NotificationsPage(),
          binding: BindingsBuilder.put(() => Notifications()),
        ),
        GetPage(
          name: EditEntryPage.ROUTE,
          page: () => EditEntryPage(Get.arguments[0], Get.arguments[2]),
          binding: BindingsBuilder.put(
            () => Entry(Get.arguments[0], Get.arguments[1]),
          ),
        ),
        GetPage(
          name: FilterPage.ROUTE,
          page: () => FilterPage(Get.arguments[0], Get.arguments[1]),
        ),
        GetPage(
          name: FavouritesPage.ROUTE,
          page: () => FavouritesPage(Get.arguments),
        ),
        GetPage(
          name: UserActivitiesPage.ROUTE,
          page: () => UserActivitiesPage(Get.arguments),
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
