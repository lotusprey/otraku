import 'package:flutter/material.dart';
import 'package:otraku/views/activity_view.dart';
import 'package:otraku/views/auth_view.dart';
import 'package:otraku/views/character_view.dart';
import 'package:otraku/views/collection_view.dart';
import 'package:otraku/views/favourites_view.dart';
import 'package:otraku/views/feed_view.dart';
import 'package:otraku/views/filter_view.dart';
import 'package:otraku/views/friends_view.dart';
import 'package:otraku/views/home_view.dart';
import 'package:otraku/views/media_view.dart';
import 'package:otraku/views/notifications_view.dart';
import 'package:otraku/views/review_view.dart';
import 'package:otraku/views/settings_view.dart';
import 'package:otraku/views/staff_view.dart';
import 'package:otraku/views/statistics_view.dart';
import 'package:otraku/views/studio_view.dart';
import 'package:otraku/views/reviews_view.dart';
import 'package:otraku/views/user_view.dart';

/// A routing helper. When passing arguments to named routes, they should always
/// be an instance of [RouteArg] or [null].
class RouteArg {
  const RouteArg({
    this.id,
    this.info,
    this.variant,
    this.callback,
  });

  final int? id;
  final String? info;
  final bool? variant;
  final Function? callback;

  /// Used to provide context when it's unavailable
  /// through [RouteArg.navKey.currentContext].
  static final navKey = GlobalKey<NavigatorState>();

  /// Used by [MaterialApp.onGenerateRoute].
  static Route<dynamic>? generateRoute(RouteSettings route) {
    if (route.arguments is! RouteArg?) return _unknown();

    final arg = route.arguments as RouteArg?;
    switch (route.name) {
      case auth:
        return MaterialPageRoute(builder: (_) => const AuthView());
      case home:
        if (arg?.id == null) return _unknown();
        return MaterialPageRoute(builder: (_) => HomeView(arg!.id!));
      case settings:
        return MaterialPageRoute(builder: (_) => SettingsView());
      case notifications:
        return MaterialPageRoute(builder: (_) => NotificationsView());
      case collection:
        if (arg?.id == null || arg?.variant == null) return _unknown();
        return MaterialPageRoute(
          builder: (_) => CollectionView(arg!.id!, arg.variant!),
        );
      case media:
        if (arg?.id == null) return _unknown();
        return MaterialPageRoute(
          builder: (_) => MediaView(arg!.id!, arg.info),
        );
      case character:
        if (arg?.id == null) return _unknown();
        return MaterialPageRoute(
          builder: (_) => CharacterView(arg!.id!, arg.info),
        );
      case staff:
        if (arg?.id == null) return _unknown();
        return MaterialPageRoute(builder: (_) => StaffView(arg!.id!, arg.info));
      case studio:
        if (arg?.id == null) return _unknown();
        return MaterialPageRoute(
          builder: (_) => StudioView(arg!.id!, arg.info),
        );
      case review:
        if (arg?.id == null) return _unknown();
        return MaterialPageRoute(
          builder: (_) => ReviewView(arg!.id!, arg.info),
        );
      case user:
        if (arg?.id == null) return _unknown();
        return MaterialPageRoute(builder: (_) => UserView(arg!.id!, arg.info));
      case feed:
        if (arg?.id == null) return _unknown();
        return MaterialPageRoute(builder: (_) => FeedView(arg!.id!));
      case favourites:
        if (arg?.id == null) return _unknown();
        return MaterialPageRoute(builder: (_) => FavouritesView(arg!.id!));
      case friends:
        if (arg?.id == null || arg?.variant == null) return _unknown();
        return MaterialPageRoute(
          builder: (_) => FriendsView(arg!.id!, arg.variant!),
        );
      case statistics:
        if (arg?.id == null) return _unknown();
        return MaterialPageRoute(builder: (_) => StatisticsView(arg!.id!));
      case reviews:
        if (arg?.id == null) return _unknown();
        return MaterialPageRoute(builder: (_) => ReviewsView(arg!.id!));
      case activity:
        if (arg?.id == null) return _unknown();
        return MaterialPageRoute(
          builder: (_) => ActivityView(arg!.id!, arg.info),
        );
      case filters:
        if (arg?.callback is! void Function(bool)) return _unknown();
        return MaterialPageRoute(
          builder: (_) => FiltersView(
            arg!.info,
            arg.callback as void Function(bool),
          ),
        );
      default:
        return null;
    }
  }

  // Available routes.
  static const auth = '/auth';
  static const home = '/home';
  static const settings = '/settings';
  static const notifications = '/notifications';
  static const collection = '/collection';
  static const media = '/media';
  static const character = '/character';
  static const staff = '/staff';
  static const studio = '/studio';
  static const review = '/review';
  static const user = '/user';
  static const feed = '/feed';
  static const favourites = '/favourites';
  static const friends = '/friends';
  static const statistics = '/statistics';
  static const reviews = '/reviews';
  static const activity = '/activity';
  static const filters = '/filters';
  static const thread = '/thread';

  // A placeholder for unknown routes.
  static Route<dynamic> _unknown() => MaterialPageRoute(
        builder: (ctx) => Scaffold(
          body: Center(
            child: Text('404', style: Theme.of(ctx).textTheme.headline1),
          ),
        ),
      );
}
