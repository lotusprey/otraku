import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otraku/controllers/activity_controller.dart';
import 'package:otraku/controllers/character_controller.dart';
import 'package:otraku/controllers/collection_controller.dart';
import 'package:otraku/controllers/explore_controller.dart';
import 'package:otraku/controllers/favourites_controller.dart';
import 'package:otraku/controllers/feed_controller.dart';
import 'package:otraku/controllers/friends_controller.dart';
import 'package:otraku/controllers/media_controller.dart';
import 'package:otraku/controllers/notifications_controller.dart';
import 'package:otraku/controllers/review_controller.dart';
import 'package:otraku/controllers/staff_controller.dart';
import 'package:otraku/controllers/statistics_controller.dart';
import 'package:otraku/controllers/studio_controller.dart';
import 'package:otraku/controllers/user_controller.dart';
import 'package:otraku/controllers/user_reviews_controller.dart';
import 'package:otraku/views/activity_view.dart';
import 'package:otraku/views/auth_view.dart';
import 'package:otraku/views/character_view.dart';
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

  static const authRoute = '/auth';
  static const homeRoute = '/home';
  static const settingsRoute = '/settings';
  static const notificationsRoute = '/notifications';
  static const collectionRoute = '/collection';
  static const mediaRoute = '/media';
  static const characterRoute = '/character';
  static const staffRoute = '/staff';
  static const studioRoute = '/studio';
  static const reviewRoute = '/review';
  static const userRoute = '/user';
  static const feedRoute = '/feed';
  static const favouritesRoute = '/favourites';
  static const friendsRoute = '/friends';
  static const statisticsRoute = '/statistics';
  static const userReviewsRoute = '/userReviews';
  static const activityRoute = '/activity';
  static const filtersRoute = '/filters';
  static const threadRoute = '/thread';

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
        Get.put(ExploreController());
        _add(route, HomeView(), args, null);
        break;
      case settingsRoute:
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
  //
  // Controllers are deleted after the page is popped,
  // as some widgets may depend on them.
  bool _pop({bool notify = true}) {
    if (_pages.length <= 1) return false;

    final page = _pages.removeLast();
    if (notify) notifyListeners();

    switch (page.name) {
      case homeRoute:
        Get.delete<CollectionController>(tag: CollectionController.ANIME);
        Get.delete<CollectionController>(tag: CollectionController.MANGA);
        Get.delete<UserController>(tag: Client.viewerId.toString());
        Get.delete<FeedController>(tag: FeedController.HOME_FEED_TAG);
        Get.delete<ExploreController>();
        break;
      case notificationsRoute:
        Get.delete<NotificationsController>();
        break;
      case collectionRoute:
        if (_isPageUnique(page))
          Get.delete<CollectionController>(tag: page.tag);
        break;
      case mediaRoute:
        if (_isPageUnique(page)) Get.delete<MediaController>(tag: page.tag);
        break;
      case characterRoute:
        if (_isPageUnique(page)) Get.delete<CharacterController>(tag: page.tag);
        break;
      case staffRoute:
        if (_isPageUnique(page)) Get.delete<StaffController>(tag: page.tag);
        break;
      case studioRoute:
        if (_isPageUnique(page)) Get.delete<StudioController>(tag: page.tag);
        break;
      case reviewRoute:
        if (_isPageUnique(page)) Get.delete<ReviewController>(tag: page.tag);
        break;
      case userRoute:
        if (_isPageUnique(page)) Get.delete<UserController>(tag: page.tag);
        break;
      case feedRoute:
        if (_isPageUnique(page)) Get.delete<FeedController>(tag: page.tag);
        break;
      case favouritesRoute:
        if (_isPageUnique(page))
          Get.delete<FavouritesController>(tag: page.tag);
        break;
      case friendsRoute:
        if (_isPageUnique(page)) Get.delete<FriendsController>(tag: page.tag);
        break;
      case statisticsRoute:
        if (_isPageUnique(page))
          Get.delete<StatisticsController>(tag: page.tag);
        break;
      case userReviewsRoute:
        if (_isPageUnique(page))
          Get.delete<UserReviewsController>(tag: page.tag);
        break;
      case activityRoute:
        if (_isPageUnique(page)) Get.delete<ActivityController>(tag: page.tag);
        break;
      default:
        break;
    }

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

  // Checks if there is a page with the same name & tag in the stack as [page].
  // If there is, its controller(s) shouldn't be deleted, on [page] pop.
  //
  // When calling this function, [page] shouldn't be
  // in the stack (it should already be popped).
  //
  // This function is meant for pages
  // with uniquely tagged controllers.
  bool _isPageUnique(RoutePage page) {
    if (page.tag == null) return false;

    for (int i = 0; i < _pages.length; i++)
      if (_pages[i].name == page.name && _pages[i].tag == page.tag)
        return false;

    return true;
  }

  // This override will be needed in the future for web.
  // @override
  // T? get currentConfiguration => null;
}
