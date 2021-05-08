import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:otraku/controllers/activity.dart';
import 'package:otraku/controllers/character.dart';
import 'package:otraku/controllers/collection.dart';
import 'package:otraku/controllers/entry.dart';
import 'package:otraku/controllers/explorer.dart';
import 'package:otraku/controllers/favourites.dart';
import 'package:otraku/controllers/friends.dart';
import 'package:otraku/controllers/media.dart';
import 'package:otraku/controllers/notifications.dart';
import 'package:otraku/controllers/review.dart';
import 'package:otraku/controllers/settings.dart';
import 'package:otraku/controllers/staff.dart';
import 'package:otraku/controllers/statistics.dart';
import 'package:otraku/controllers/studio.dart';
import 'package:otraku/controllers/user.dart';
import 'package:otraku/controllers/user_feed.dart';
import 'package:otraku/controllers/user_reviews.dart';
import 'package:otraku/controllers/viewer.dart';
import 'package:otraku/pages/friends_page.dart';
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
import 'package:otraku/pages/user_feed_page.dart';
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

  BackgroundHandler.init();

  runApp(App());
}

// TODO getNotificationAppLaunchDetails

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Otraku',
      theme: Config.theme,
      // TODO a workaround due to getx not being able to change the dark theme
      themeMode: ThemeMode.light,
      initialRoute: AuthPage.ROUTE,
      getPages: [
        GetPage(name: AuthPage.ROUTE, page: () => AuthPage()),
        GetPage(
          name: HomePage.ROUTE,
          page: () => HomePage(),
          binding: BindingsBuilder(() {
            Get.put(Collection(Client.viewerId!, true), tag: Collection.ANIME);
            Get.put(Collection(Client.viewerId!, false), tag: Collection.MANGA);
            Get.put(User(Client.viewerId!), tag: Client.viewerId.toString());
            Get.put(Explorer());
            Get.put(Viewer());
          }),
        ),
        GetPage(
          name: UserPage.ROUTE,
          page: () => UserPage(Get.arguments[0], Get.arguments[1]),
          binding: BindingsBuilder(() {
            Get.put(User(Get.arguments[0]), tag: Get.arguments[0].toString());
          }),
        ),
        GetPage(
          name: CollectionPage.ROUTE,
          page: () => CollectionPage(
            id: Get.arguments[0],
            ofAnime: Get.arguments[1],
            collectionTag: Get.arguments[2],
          ),
          binding: BindingsBuilder(() {
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
            Get.put(
              Activity(Get.arguments[0], Get.arguments[1], Get.arguments[2]),
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
          name: EntryPage.ROUTE,
          page: () => EntryPage(Get.arguments[0], Get.arguments[2]),
          binding: BindingsBuilder.put(
            () => Entry(Get.arguments[0], Get.arguments[1]),
          ),
        ),
        GetPage(
          name: FavouritesPage.ROUTE,
          page: () => FavouritesPage(Get.arguments),
          binding: BindingsBuilder(() {
            Get.put(Favourites(Get.arguments), tag: Get.arguments.toString());
          }),
        ),
        GetPage(
          name: FriendsPage.ROUTE,
          page: () => FriendsPage(Get.arguments[0]),
          binding: BindingsBuilder(() {
            Get.put(
              Friends(Get.arguments[0], Get.arguments[1]),
              tag: Get.arguments[0].toString(),
            );
          }),
        ),
        GetPage(
          name: UserFeedPage.ROUTE,
          page: () => UserFeedPage(Get.arguments),
          binding: BindingsBuilder(() {
            Get.put(UserFeed(Get.arguments), tag: Get.arguments.toString());
          }),
        ),
        GetPage(
          name: UserReviewsPage.ROUTE,
          page: () => UserReviewsPage(Get.arguments),
          binding: BindingsBuilder(() {
            Get.put(UserReviews(Get.arguments), tag: Get.arguments.toString());
          }),
        ),
        GetPage(
          name: StatisticsPage.ROUTE,
          page: () => StatisticsPage(Get.arguments),
          binding: BindingsBuilder(() {
            Get.put(Statistics(Get.arguments), tag: Get.arguments.toString());
          }),
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
