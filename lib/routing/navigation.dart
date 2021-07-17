import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
import 'package:otraku/models/entry_model.dart';
import 'package:otraku/views/activity_view.dart';
import 'package:otraku/views/auth_view.dart';
import 'package:otraku/views/character_view.dart';
import 'package:otraku/views/entry_view.dart';
import 'package:otraku/views/favourites_view.dart';
import 'package:otraku/views/filter_view.dart';
import 'package:otraku/views/friends_view.dart';
import 'package:otraku/views/collection_view.dart';
import 'package:otraku/views/feed_view.dart';
import 'package:otraku/views/home_view.dart';
import 'package:otraku/views/user_view.dart';
import 'package:otraku/views/media_view.dart';
import 'package:otraku/views/notifications_view.dart';
import 'package:otraku/views/review_view.dart';
import 'package:otraku/views/settings_view.dart';
import 'package:otraku/views/staff_view.dart';
import 'package:otraku/views/statistics_view.dart';
import 'package:otraku/views/studio_view.dart';
import 'package:otraku/views/user_reviews_view.dart';
import 'package:otraku/utils/client.dart';
import 'package:otraku/routing/route_page.dart';

class Navigation extends RouterDelegate<String>
    with PopNavigatorRouterDelegateMixin<String>, ChangeNotifier {
  Navigation._() {
    push(authRoute);
  }

  static final it = Navigation._();

  static const authRoute = 'auth';
  static const homeRoute = 'home';
  static const settingsRoute = 'settings';
  static const notificationsRoute = 'notifications';
  static const collectionRoute = 'collection';
  static const mediaRoute = 'media';
  static const entryRoute = 'entry';
  static const characterRoute = 'character';
  static const staffRoute = 'staff';
  static const studioRoute = 'studio';
  static const reviewRoute = 'review';
  static const userRoute = 'user';
  static const feedRoute = 'feed';
  static const favouritesRoute = 'favourites';
  static const friendsRoute = 'friends';
  static const statisticsRoute = 'statistics';
  static const userReviewsRoute = 'userReviews';
  static const activityRoute = 'activity';
  static const filtersRoute = 'filters';
  static const threadRoute = 'thread';

  final _pages = <RoutePage>[];
  final _key = GlobalKey<NavigatorState>();

  // Gets the current context.
  BuildContext? get ctx => _key.currentContext;

  @override
  GlobalKey<NavigatorState> get navigatorKey => _key;

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: _key,
      pages: List.of(_pages),
      onPopPage: (route, result) {
        if (!route.didPop(result)) return false;
        return _pop();
      },
    );
  }

  void _add(String route, Widget child, List<dynamic> args, String? tag) =>
      _pages.add(RoutePage(name: route, child: child, args: args, tag: tag));

  // Pushes a page and adds related controllers, if needed.
  void push(String route, {List<dynamic> args = const [], bool notify = true}) {
    switch (route) {
      case authRoute:
        _add(route, AuthView(), args, null);
        break;
      case homeRoute:
        Get.put(
          CollectionController(Client.viewerId!, true),
          tag: CollectionController.ANIME,
        );
        Get.put(
          CollectionController(Client.viewerId!, false),
          tag: CollectionController.MANGA,
        );
        Get.put(
          UserController(Client.viewerId!),
          tag: Client.viewerId.toString(),
        );
        Get.put(FeedController(null), tag: FeedController.HOME_FEED_TAG);
        Get.put(ExplorerController());
        Get.put(ViewerController());
        _add(route, HomeView(), args, null);
        break;
      case settingsRoute:
        Get.put(SettingsController());
        _add(route, SettingsView(), args, null);
        break;
      case notificationsRoute:
        Get.put(NotificationsController());
        _add(route, NotificationsView(), args, null);
        break;
      case collectionRoute:
        if (args.length < 2 || args[0] is! int || args[1] is! bool) return;

        final int id = args[0];
        final bool ofAnime = args[1];
        final String tag =
            '${ofAnime ? CollectionController.ANIME : CollectionController.MANGA}$id';

        Get.put(CollectionController(id, ofAnime), tag: tag);
        _add(
          route,
          CollectionView(id: id, ofAnime: ofAnime, ctrlTag: tag),
          args,
          tag,
        );
        break;
      case mediaRoute:
        if (args.length < 2 || args[0] is! int || args[1] is! String?) return;

        final int id = args[0];
        final String? image = args[1];

        Get.put(MediaController(id), tag: id.toString());
        _add(route, MediaView(id, image), args, id.toString());
        break;
      case entryRoute:
        if (args.length < 3 || args[0] is! int || args[1] is! EntryModel?)
          return;
        if (args[2] is! Function(EntryModel)?) return;

        final int id = args[0];
        final EntryModel? model = args[1];
        final Function(EntryModel)? callback = args[2];

        Get.put(EntryController(id, model), tag: id.toString());
        _add(route, EntryView(id, callback), args, id.toString());
        break;
      case characterRoute:
        if (args.length < 2 || args[0] is! int || args[1] is! String) return;

        final int id = args[0];
        final String image = args[1];

        Get.put(CharacterController(id), tag: id.toString());
        _add(route, CharacterView(id, image), args, id.toString());
        break;
      case staffRoute:
        if (args.length < 2 || args[0] is! int || args[1] is! String) return;

        final int id = args[0];
        final String image = args[1];

        Get.put(StaffController(id), tag: id.toString());
        _add(route, StaffView(id, image), args, id.toString());
        break;
      case studioRoute:
        if (args.length < 2 || args[0] is! int || args[1] is! String) return;

        final int id = args[0];
        final String name = args[1];

        Get.put(StudioController(id), tag: id.toString());
        _add(route, StudioView(id, name), args, id.toString());
        break;
      case reviewRoute:
        if (args.length < 2 || args[0] is! int || args[1] is! String?) return;

        final int id = args[0];
        final String? image = args[1];

        Get.put(ReviewController(id), tag: id.toString());
        _add(route, ReviewView(id, image), args, id.toString());
        break;
      case userRoute:
        if (args.length < 2 || args[0] is! int || args[1] is! String?) return;

        final int id = args[0];
        final String? image = args[1];

        Get.put(UserController(id), tag: id.toString());
        _add(route, UserView(id, image), args, id.toString());
        break;
      case feedRoute:
        if (args.length < 1 || args[0] is! int) return;

        final int id = args[0];

        Get.put(FeedController(id), tag: id.toString());
        _add(route, FeedView(id), args, id.toString());
        break;
      case favouritesRoute:
        if (args.length < 1 || args[0] is! int) return;

        final int id = args[0];

        Get.put(FavouritesController(id), tag: id.toString());
        _add(route, FavouritesView(id), args, id.toString());
        break;
      case friendsRoute:
        if (args.length < 2 || args[0] is! int || args[1] is! bool) return;

        final int id = args[0];
        final bool onFollowing = args[1];

        Get.put(FriendsController(id, onFollowing), tag: id.toString());
        _add(route, FriendsView(id), args, id.toString());
        break;
      case statisticsRoute:
        if (args.length < 1 || args[0] is! int) return;

        final int id = args[0];

        Get.put(StatisticsController(id), tag: id.toString());
        _add(route, StatisticsView(id), args, id.toString());
        break;
      case userReviewsRoute:
        if (args.length < 1 || args[0] is! int) return;

        final int id = args[0];

        Get.put(UserReviewsController(id), tag: id.toString());
        _add(route, UserReviewsView(id), args, id.toString());
        break;
      case activityRoute:
        if (args.length < 2 || args[0] is! int || args[1] is! String?) return;

        final int id = args[0];
        final String? feedTag = args[1];

        Get.put(ActivityController(id, feedTag), tag: id.toString());
        _add(route, ActivityView(id), args, id.toString());
        break;
      case filtersRoute:
        if (args.length < 2 ||
            args[1] is! void Function(bool) ||
            args[0] is! String?) return;

        final String? collectionTag = args[0];
        final void Function(bool) isDefinitelyInactive = args[1];

        _add(
          route,
          FilterView(collectionTag, isDefinitelyInactive),
          args,
          null,
        );
        break;
      default:
        break;
    }

    if (notify) notifyListeners();
  }

  // Pops a page and deletes related controllers, if possible.
  //
  // It's private, as using Navigator.pop(context) is preferred. This is due
  // to a tricky error that may occur when a page is popped too early. When
  // context isn't available in the scope, use Navigation.ctx to acquire it.
  bool _pop({bool notify = true}) {
    if (_pages.length <= 1) return false;

    switch (_pages.last.name) {
      case homeRoute:
        Get.delete<CollectionController>(tag: CollectionController.ANIME);
        Get.delete<CollectionController>(tag: CollectionController.MANGA);
        Get.delete<UserController>(tag: Client.viewerId.toString());
        Get.delete<FeedController>(tag: FeedController.HOME_FEED_TAG);
        Get.delete<ExplorerController>();
        Get.delete<ViewerController>();
        break;
      case settingsRoute:
        Get.delete<SettingsController>();
        break;
      case notificationsRoute:
        Get.delete<NotificationsController>();
        break;
      case collectionRoute:
        if (_lastPageIsUnique())
          Get.delete<CollectionController>(tag: _pages.last.tag);
        break;
      case mediaRoute:
        if (_lastPageIsUnique())
          Get.delete<MediaController>(tag: _pages.last.tag);
        break;
      case entryRoute:
        if (_lastPageIsUnique())
          Get.delete<EntryController>(tag: _pages.last.tag);
        break;
      case characterRoute:
        if (_lastPageIsUnique())
          Get.delete<CharacterController>(tag: _pages.last.tag);
        break;
      case staffRoute:
        if (_lastPageIsUnique())
          Get.delete<StaffController>(tag: _pages.last.tag);
        break;
      case studioRoute:
        if (_lastPageIsUnique())
          Get.delete<StudioController>(tag: _pages.last.tag);
        break;
      case reviewRoute:
        if (_lastPageIsUnique())
          Get.delete<ReviewController>(tag: _pages.last.tag);
        break;
      case userRoute:
        if (_lastPageIsUnique())
          Get.delete<UserController>(tag: _pages.last.tag);
        break;
      case feedRoute:
        if (_lastPageIsUnique())
          Get.delete<FeedController>(tag: _pages.last.tag);
        break;
      case favouritesRoute:
        if (_lastPageIsUnique())
          Get.delete<FavouritesController>(tag: _pages.last.tag);
        break;
      case friendsRoute:
        if (_lastPageIsUnique())
          Get.delete<FriendsController>(tag: _pages.last.tag);
        break;
      case statisticsRoute:
        if (_lastPageIsUnique())
          Get.delete<StatisticsController>(tag: _pages.last.tag);
        break;
      case userReviewsRoute:
        if (_lastPageIsUnique())
          Get.delete<UserReviewsController>(tag: _pages.last.tag);
        break;
      case activityRoute:
        if (_lastPageIsUnique())
          Get.delete<ActivityController>(tag: _pages.last.tag);
        break;
      default:
        break;
    }

    _pages.removeLast();
    if (notify) notifyListeners();
    return true;
  }

  // Pops pages, until there is one left.
  void popToFirst() {
    while (_pop(notify: false)) {}
    notifyListeners();
  }

  // Replaces all pages with a new page.
  void setBasePage(String route) {
    Get.reset();
    _pages.clear();
    push(route);
  }

  // Replaces all pages above the base one with a new page.
  void setTopPage(String route) {
    popToFirst();
    push(route);
  }

  // Checks if this page is the only one with these route and tag. If it isn't,
  // its controller shouldn't be deleted, when the page is popped.
  // This function should only be called for pages with uniquely
  // tagged controllers.
  bool _lastPageIsUnique() {
    if (_pages.last.tag == null) return false;

    final name = _pages.last.name;
    final tag = _pages.last.tag;
    for (int i = 0; i < _pages.length - 1; i++)
      if (_pages[i].name == name && _pages[i].tag == tag) return false;

    return true;
  }

  @override
  Future<bool> popRoute() async {
    if (_key.currentContext == null) return SynchronousFuture(true);

    return Navigator.maybePop(_key.currentContext!);
  }

  @override
  Future<void> setNewRoutePath(String route) {
    // Don't go to authentication if the user is authenticated or already there.
    if (route == authRoute) {
      if (_pages.isNotEmpty && _pages.last.name == authRoute)
        return SynchronousFuture(null);

      if (Client.loggedIn()) return SynchronousFuture(null);
    }

    // Only auth and home pages can be at the root.
    if (route == authRoute || route == homeRoute)
      setBasePage(route);
    else
      setTopPage(route);

    return SynchronousFuture(null);
  }

  // This override will be needed in the future for web.
  // @override
  // T? get currentConfiguration => null;
}
