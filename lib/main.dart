import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:otraku/controllers/activity_controller.dart';
import 'package:otraku/controllers/character_controller.dart';
import 'package:otraku/controllers/collection_controller.dart';
import 'package:otraku/controllers/entry_controller.dart';
import 'package:otraku/controllers/explorer_controller.dart';
import 'package:otraku/controllers/favourites_controller.dart';
import 'package:otraku/controllers/feed_controller.dart';
import 'package:otraku/controllers/friends_controller.dart';
import 'package:otraku/controllers/media_controller.dart';
import 'package:otraku/controllers/notifications_controller.dart';
import 'package:otraku/controllers/review_controller.dart';
import 'package:otraku/controllers/settings_controller.dart';
import 'package:otraku/controllers/staff_controller.dart';
import 'package:otraku/controllers/statistics_controller.dart';
import 'package:otraku/controllers/studio_controller.dart';
import 'package:otraku/controllers/user_controller.dart';
import 'package:otraku/controllers/user_reviews_controller.dart';
import 'package:otraku/controllers/viewer_controller.dart';
import 'package:otraku/pages/friends_page.dart';
import 'package:otraku/pages/home/feed_page.dart';
import 'package:otraku/pages/statistics_page.dart';
import 'package:otraku/pages/user_reviews_page.dart';
import 'package:otraku/utils/background_handler.dart';
import 'package:otraku/utils/config.dart';
import 'package:otraku/utils/client.dart';
import 'package:otraku/pages/auth_page.dart';
import 'package:otraku/pages/home/collection_page.dart';
import 'package:otraku/pages/home/home_page.dart';
import 'package:otraku/pages/home/user_page.dart';
import 'package:otraku/pages/media/media_page.dart';
import 'package:otraku/pages/activity_page.dart';
import 'package:otraku/pages/character_page.dart';
import 'package:otraku/pages/entry_page.dart';
import 'package:otraku/pages/favourites_page.dart';
import 'package:otraku/pages/filter_page.dart';
import 'package:otraku/pages/notifications_page.dart';
import 'package:otraku/pages/review_page.dart';
import 'package:otraku/pages/staff_page.dart';
import 'package:otraku/pages/studio_page.dart';
import 'package:otraku/pages/settings/settings_page.dart';

Future<void> main() async {
  await GetStorage.init();
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    BackgroundHandler.init(context);

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Otraku',
      theme: Config.theme,
      // A workaround due to getx not being able to change the dark theme
      themeMode: ThemeMode.light,
      initialRoute: AuthPage.ROUTE,
      getPages: [
        GetPage(name: AuthPage.ROUTE, page: () => AuthPage()),
        GetPage(
          name: HomePage.ROUTE,
          page: () => HomePage(),
          binding: BindingsBuilder(() {
            Get.put(CollectionController(Client.viewerId!, true),
                tag: CollectionController.ANIME);
            Get.put(CollectionController(Client.viewerId!, false),
                tag: CollectionController.MANGA);
            Get.put(UserController(Client.viewerId!),
                tag: Client.viewerId.toString());
            Get.put(FeedController(null), tag: FeedController.HOME_FEED_TAG);
            Get.put(ExplorerController());
            Get.put(ViewerController());
          }),
        ),
        GetPage(
          name: UserPage.ROUTE,
          page: () => UserPage(Get.arguments[0], Get.arguments[1]),
          binding: BindingsBuilder(() {
            Get.put(UserController(Get.arguments[0]),
                tag: Get.arguments[0].toString());
          }),
        ),
        GetPage(
          name: CollectionPage.ROUTE,
          page: () => CollectionPage(
            id: Get.arguments[0],
            ofAnime: Get.arguments[1],
            ctrlTag: Get.arguments[2],
          ),
          binding: BindingsBuilder(() {
            Get.put(
              CollectionController(Get.arguments[0], Get.arguments[1]),
              tag: Get.arguments[2],
            );
          }),
        ),
        GetPage(
          name: MediaPage.ROUTE,
          page: () => MediaPage(Get.arguments[0], Get.arguments[1]),
          binding: BindingsBuilder(() {
            Get.put(
              MediaController(Get.arguments[0]),
              tag: Get.arguments[0].toString(),
            );
          }),
        ),
        GetPage(
          name: CharacterPage.ROUTE,
          page: () => CharacterPage(Get.arguments[0], Get.arguments[1]),
          binding: BindingsBuilder(() {
            Get.put(
              CharacterController(Get.arguments[0]),
              tag: Get.arguments[0].toString(),
            );
          }),
        ),
        GetPage(
          name: StaffPage.ROUTE,
          page: () => StaffPage(Get.arguments[0], Get.arguments[1]),
          binding: BindingsBuilder(() {
            Get.put(
              StaffController(Get.arguments[0]),
              tag: Get.arguments[0].toString(),
            );
          }),
        ),
        GetPage(
          name: StudioPage.ROUTE,
          page: () => StudioPage(Get.arguments[0], Get.arguments[1]),
          binding: BindingsBuilder(() {
            Get.put(
              StudioController(Get.arguments[0]),
              tag: Get.arguments[0].toString(),
            );
          }),
        ),
        GetPage(
          name: ReviewPage.ROUTE,
          page: () => ReviewPage(Get.arguments[0], Get.arguments[1]),
          binding: BindingsBuilder(() {
            Get.put(
              ReviewController(Get.arguments[0]),
              tag: Get.arguments[0].toString(),
            );
          }),
        ),
        GetPage(
          name: ActivityPage.ROUTE,
          page: () => ActivityPage(Get.arguments[0]),
          binding: BindingsBuilder(() {
            Get.put(
              ActivityController(Get.arguments[0], Get.arguments[1]),
              tag: Get.arguments[0].toString(),
            );
          }),
        ),
        GetPage(
          name: NotificationsPage.ROUTE,
          page: () => NotificationsPage(),
          binding: BindingsBuilder.put(() => NotificationsController()),
        ),
        GetPage(
          name: EntryPage.ROUTE,
          page: () => EntryPage(Get.arguments[0], Get.arguments[2]),
          binding: BindingsBuilder(() {
            Get.put(
              EntryController(Get.arguments[0], Get.arguments[1]),
              tag: Get.arguments[0].toString(),
            );
          }),
        ),
        GetPage(
          name: FavouritesPage.ROUTE,
          page: () => FavouritesPage(Get.arguments[0]),
          binding: BindingsBuilder(() {
            Get.put(FavouritesController(Get.arguments[0]),
                tag: Get.arguments[0].toString());
          }),
        ),
        GetPage(
          name: FriendsPage.ROUTE,
          page: () => FriendsPage(Get.arguments[0]),
          binding: BindingsBuilder(() {
            Get.put(
              FriendsController(Get.arguments[0], Get.arguments[1]),
              tag: Get.arguments[0].toString(),
            );
          }),
        ),
        GetPage(
          name: FeedPage.ROUTE,
          page: () => FeedPage(Get.arguments[0]),
          binding: BindingsBuilder(() {
            Get.put(FeedController(Get.arguments[0]),
                tag: Get.arguments[0].toString());
          }),
        ),
        GetPage(
          name: UserReviewsPage.ROUTE,
          page: () => UserReviewsPage(Get.arguments[0]),
          binding: BindingsBuilder(() {
            Get.put(UserReviewsController(Get.arguments[0]),
                tag: Get.arguments[0].toString());
          }),
        ),
        GetPage(
          name: StatisticsPage.ROUTE,
          page: () => StatisticsPage(Get.arguments[0]),
          binding: BindingsBuilder(() {
            Get.put(StatisticsController(Get.arguments[0]),
                tag: Get.arguments[0].toString());
          }),
        ),
        GetPage(
          name: FilterPage.ROUTE,
          page: () => FilterPage(Get.arguments[0], Get.arguments[1]),
        ),
        GetPage(
          name: SettingsPage.ROUTE,
          page: () => SettingsPage(),
          binding: BindingsBuilder.put(() => SettingsController()),
        ),
      ],
    );
  }
}
