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
import 'package:otraku/enums/list_status.dart';
import 'package:otraku/models/entry_model.dart';
import 'package:otraku/pages/activity_page.dart';
import 'package:otraku/pages/auth_page.dart';
import 'package:otraku/pages/character_page.dart';
import 'package:otraku/pages/entry_page.dart';
import 'package:otraku/pages/favourites_page.dart';
import 'package:otraku/pages/filter_page.dart';
import 'package:otraku/pages/friends_page.dart';
import 'package:otraku/pages/home/collection_page.dart';
import 'package:otraku/pages/home/feed_page.dart';
import 'package:otraku/pages/home/home_page.dart';
import 'package:otraku/pages/home/user_page.dart';
import 'package:otraku/pages/media/media_page.dart';
import 'package:otraku/pages/notifications_page.dart';
import 'package:otraku/pages/review_page.dart';
import 'package:otraku/pages/settings/settings_page.dart';
import 'package:otraku/pages/splash_page.dart';
import 'package:otraku/pages/staff_page.dart';
import 'package:otraku/pages/statistics_page.dart';
import 'package:otraku/pages/studio_page.dart';
import 'package:otraku/pages/unknown_page.dart';
import 'package:otraku/pages/user_reviews_page.dart';
import 'package:otraku/utils/client.dart';
import 'package:otraku/routing/route_page.dart';
import 'package:otraku/widgets/overlays/dialogs.dart';

class Navigation extends RouterDelegate<String>
    with PopNavigatorRouterDelegateMixin<String>, ChangeNotifier {
  Navigation._() {
    push(splashRoute);
  }

  static final it = Navigation._();

  static const authRoute = '/auth';
  static const homeRoute = '/home';
  static const settingsRoute = '/settings';
  static const notificationsRoute = '/notifications';
  static const collectionRoute = '/collection';
  static const mediaRoute = '/media';
  static const entryRoute = '/entry';
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
  static const unknownRoute = '/404';
  static const splashRoute = '/splash';

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
    print('pushing $route');
    switch (route) {
      case authRoute:
        _add(route, AuthPage(), args, null);
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
        _add(route, HomePage(), args, null);
        break;
      case settingsRoute:
        Get.put(SettingsController());
        _add(route, SettingsPage(), args, null);
        break;
      case notificationsRoute:
        Get.put(NotificationsController());
        _add(route, NotificationsPage(), args, null);
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
          CollectionPage(id: id, ofAnime: ofAnime, ctrlTag: tag),
          args,
          tag,
        );
        break;
      case mediaRoute:
        if (args.length < 2 || args[0] is! int || args[1] is! String?) return;

        final int id = args[0];
        final String? image = args[1];

        Get.put(MediaController(id), tag: id.toString());
        _add(route, MediaPage(id, image), args, id.toString());
        break;
      case entryRoute:
        if (args.length < 3 || args[0] is! int || args[1] is! EntryModel?)
          return;
        if (args[2] is! Function(ListStatus?)?) return;

        final int id = args[0];
        final EntryModel? model = args[1];
        final Function(ListStatus?)? callback = args[2];

        Get.put(EntryController(id, model), tag: id.toString());
        _add(route, EntryPage(id, callback), args, id.toString());
        break;
      case characterRoute:
        if (args.length < 2 || args[0] is! int || args[1] is! String) return;

        final int id = args[0];
        final String image = args[1];

        Get.put(CharacterController(id), tag: id.toString());
        _add(route, CharacterPage(id, image), args, id.toString());
        break;
      case staffRoute:
        if (args.length < 2 || args[0] is! int || args[1] is! String) return;

        final int id = args[0];
        final String image = args[1];

        Get.put(StaffController(id), tag: id.toString());
        _add(route, StaffPage(id, image), args, id.toString());
        break;
      case studioRoute:
        if (args.length < 2 || args[0] is! int || args[1] is! String) return;

        final int id = args[0];
        final String name = args[1];

        Get.put(StudioController(id), tag: id.toString());
        _add(route, StudioPage(id, name), args, id.toString());
        break;
      case reviewRoute:
        if (args.length < 2 || args[0] is! int || args[1] is! String?) return;

        final int id = args[0];
        final String? image = args[1];

        Get.put(ReviewController(id), tag: id.toString());
        _add(route, ReviewPage(id, image), args, id.toString());
        break;
      case userRoute:
        if (args.length < 2 || args[0] is! int || args[1] is! String?) return;

        final int id = args[0];
        final String? image = args[1];

        Get.put(UserController(id), tag: id.toString());
        _add(route, UserPage(id, image), args, id.toString());
        break;
      case feedRoute:
        if (args.length < 1 || args[0] is! int) return;

        final int id = args[0];

        Get.put(FeedController(id), tag: id.toString());
        _add(route, FeedPage(id), args, id.toString());
        break;
      case favouritesRoute:
        if (args.length < 1 || args[0] is! int) return;

        final int id = args[0];

        Get.put(FavouritesController(id), tag: id.toString());
        _add(route, FavouritesPage(id), args, id.toString());
        break;
      case friendsRoute:
        if (args.length < 2 || args[0] is! int || args[1] is! bool) return;

        final int id = args[0];
        final bool onFollowing = args[1];

        Get.put(FriendsController(id, onFollowing), tag: id.toString());
        _add(route, FriendsPage(id), args, id.toString());
        break;
      case statisticsRoute:
        if (args.length < 1 || args[0] is! int) return;

        final int id = args[0];

        Get.put(StatisticsController(id), tag: id.toString());
        _add(route, StatisticsPage(id), args, id.toString());
        break;
      case userReviewsRoute:
        if (args.length < 1 || args[0] is! int) return;

        final int id = args[0];

        Get.put(UserReviewsController(id), tag: id.toString());
        _add(route, UserReviewsPage(id), args, id.toString());
        break;
      case activityRoute:
        if (args.length < 2 || args[0] is! int || args[1] is! String?) return;

        final int id = args[0];
        final String? feedTag = args[1];

        Get.put(ActivityController(id, feedTag), tag: id.toString());
        _add(route, ActivityPage(id), args, id.toString());
        break;
      case filtersRoute:
        if (args.length < 2 ||
            args[1] is! void Function(bool) ||
            args[0] is! String?) return;

        final String? collectionTag = args[0];
        final void Function(bool) isDefinitelyInactive = args[1];

        _add(
          route,
          FilterPage(collectionTag, isDefinitelyInactive),
          args,
          null,
        );
        break;
      case splashRoute:
        _add(splashRoute, const SplashPage(), args, null);
        break;
      default:
        _add(unknownRoute, const UnknownPage(), args, null);
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

  // Replaces all pages above the base one with a new set of pages.
  void setTopPages(List<String> routes) {
    popToFirst();
    for (final route in routes) push(route, notify: false);
    notifyListeners();
  }

  // Replaces all pages with a new page.
  void setPage(String route) {
    print('setPage $route');
    Get.reset();
    _pages.clear();
    push(route);
  }

  // Replaces all pages with a new set of pages.
  void setPages(List<String> routes) {
    Get.reset();
    _pages.clear();
    for (final route in routes) push(route, notify: false);
    notifyListeners();
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
  Future<bool> popRoute() => SynchronousFuture(_pop());

  @override
  Future<void> setNewRoutePath(String route) {
    print('setNewRoutePath $route');
    if (route == authRoute || route == homeRoute)
      setPage(route);
    else
      setTopPages([route]);
    return SynchronousFuture(null);
  }

  // This override will be needed in the future for web.
  // @override
  // T? get currentConfiguration => null;

  // Shows a dialog, by wrapping the passed child with a PopUpAnimation.
  Future<T?> dialog<T>(Widget child) {
    if (_pages.isEmpty) return Future.value(null);

    final overlayCtx = _overlayCtx;
    if (overlayCtx == null) return Future.value(null);

    if (_key.currentContext == null) return Future.value(null);

    return Navigator.of(overlayCtx, rootNavigator: true).push(DialogRoute<T>(
      context: _key.currentContext!,
      builder: (_) => PopUpAnimation(child),
    ));
  }

  // Pops an overlay.
  void closeOverlay() {
    final overlayCtx = _overlayCtx;
    if (overlayCtx == null) return;

    Navigator.of(overlayCtx, rootNavigator: true).pop();
  }

  // Gets the current overlay context.
  BuildContext? get _overlayCtx {
    BuildContext? overlay;
    _key.currentState?.overlay?.context.visitChildElements((e) => overlay = e);
    return overlay;
  }
}
