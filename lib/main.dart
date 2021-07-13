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
import 'package:otraku/views/friends_view.dart';
import 'package:otraku/views/home/feed_view.dart';
import 'package:otraku/views/statistics_view.dart';
import 'package:otraku/views/user_reviews_view.dart';
import 'package:otraku/utils/background_handler.dart';
import 'package:otraku/utils/config.dart';
import 'package:otraku/utils/client.dart';
import 'package:otraku/views/auth_view.dart';
import 'package:otraku/views/home/collection_view.dart';
import 'package:otraku/views/home/home_view.dart';
import 'package:otraku/views/home/user_view.dart';
import 'package:otraku/views/media/media_view.dart';
import 'package:otraku/views/activity_view.dart';
import 'package:otraku/views/character_view.dart';
import 'package:otraku/views/entry_view.dart';
import 'package:otraku/views/favourites_view.dart';
import 'package:otraku/views/filter_view.dart';
import 'package:otraku/views/notifications_view.dart';
import 'package:otraku/views/review_view.dart';
import 'package:otraku/views/staff_view.dart';
import 'package:otraku/views/studio_view.dart';
import 'package:otraku/views/settings/settings_view.dart';

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
      initialRoute: AuthView.ROUTE,
      getPages: [
        GetPage(name: AuthView.ROUTE, page: () => AuthView()),
        GetPage(
          name: HomeView.ROUTE,
          page: () => HomeView(),
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
          name: UserView.ROUTE,
          page: () => UserView(Get.arguments[0], Get.arguments[1]),
          binding: BindingsBuilder(() {
            Get.put(UserController(Get.arguments[0]),
                tag: Get.arguments[0].toString());
          }),
        ),
        GetPage(
          name: CollectionView.ROUTE,
          page: () => CollectionView(
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
          name: MediaView.ROUTE,
          page: () => MediaView(Get.arguments[0], Get.arguments[1]),
          binding: BindingsBuilder(() {
            Get.put(
              MediaController(Get.arguments[0]),
              tag: Get.arguments[0].toString(),
            );
          }),
        ),
        GetPage(
          name: CharacterView.ROUTE,
          page: () => CharacterView(Get.arguments[0], Get.arguments[1]),
          binding: BindingsBuilder(() {
            Get.put(
              CharacterController(Get.arguments[0]),
              tag: Get.arguments[0].toString(),
            );
          }),
        ),
        GetPage(
          name: StaffView.ROUTE,
          page: () => StaffView(Get.arguments[0], Get.arguments[1]),
          binding: BindingsBuilder(() {
            Get.put(
              StaffController(Get.arguments[0]),
              tag: Get.arguments[0].toString(),
            );
          }),
        ),
        GetPage(
          name: StudioView.ROUTE,
          page: () => StudioView(Get.arguments[0], Get.arguments[1]),
          binding: BindingsBuilder(() {
            Get.put(
              StudioController(Get.arguments[0]),
              tag: Get.arguments[0].toString(),
            );
          }),
        ),
        GetPage(
          name: ReviewView.ROUTE,
          page: () => ReviewView(Get.arguments[0], Get.arguments[1]),
          binding: BindingsBuilder(() {
            Get.put(
              ReviewController(Get.arguments[0]),
              tag: Get.arguments[0].toString(),
            );
          }),
        ),
        GetPage(
          name: ActivityView.ROUTE,
          page: () => ActivityView(Get.arguments[0]),
          binding: BindingsBuilder(() {
            Get.put(
              ActivityController(Get.arguments[0], Get.arguments[1]),
              tag: Get.arguments[0].toString(),
            );
          }),
        ),
        GetPage(
          name: NotificationsView.ROUTE,
          page: () => NotificationsView(),
          binding: BindingsBuilder.put(() => NotificationsController()),
        ),
        GetPage(
          name: EntryView.ROUTE,
          page: () => EntryView(Get.arguments[0], Get.arguments[2]),
          binding: BindingsBuilder(() {
            Get.put(
              EntryController(Get.arguments[0], Get.arguments[1]),
              tag: Get.arguments[0].toString(),
            );
          }),
        ),
        GetPage(
          name: FavouritesView.ROUTE,
          page: () => FavouritesView(Get.arguments),
          binding: BindingsBuilder(() {
            Get.put(FavouritesController(Get.arguments),
                tag: Get.arguments.toString());
          }),
        ),
        GetPage(
          name: FriendsView.ROUTE,
          page: () => FriendsView(Get.arguments[0]),
          binding: BindingsBuilder(() {
            Get.put(
              FriendsController(Get.arguments[0], Get.arguments[1]),
              tag: Get.arguments[0].toString(),
            );
          }),
        ),
        GetPage(
          name: FeedView.ROUTE,
          page: () => FeedView(Get.arguments),
          binding: BindingsBuilder(() {
            Get.put(FeedController(Get.arguments),
                tag: Get.arguments.toString());
          }),
        ),
        GetPage(
          name: UserReviewsView.ROUTE,
          page: () => UserReviewsView(Get.arguments),
          binding: BindingsBuilder(() {
            Get.put(UserReviewsController(Get.arguments),
                tag: Get.arguments.toString());
          }),
        ),
        GetPage(
          name: StatisticsView.ROUTE,
          page: () => StatisticsView(Get.arguments),
          binding: BindingsBuilder(() {
            Get.put(StatisticsController(Get.arguments),
                tag: Get.arguments.toString());
          }),
        ),
        GetPage(
          name: FilterView.ROUTE,
          page: () => FilterView(Get.arguments[0], Get.arguments[1]),
        ),
        GetPage(
          name: SettingsView.ROUTE,
          page: () => SettingsView(),
          binding: BindingsBuilder.put(() => SettingsController()),
        ),
      ],
    );
  }
}
