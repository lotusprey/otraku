import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:otraku/common/widgets/overlays/dialogs.dart';
import 'package:otraku/modules/activity/activities_view.dart';
import 'package:otraku/modules/activity/activity_view.dart';
import 'package:otraku/modules/auth/auth_view.dart';
import 'package:otraku/modules/calendar/calendar_view.dart';
import 'package:otraku/modules/character/character_view.dart';
import 'package:otraku/modules/collection/collection_view.dart';
import 'package:otraku/modules/favorites/favorites_view.dart';
import 'package:otraku/modules/home/home_provider.dart';
import 'package:otraku/modules/home/home_view.dart';
import 'package:otraku/modules/media/media_view.dart';
import 'package:otraku/modules/notification/notifications_view.dart';
import 'package:otraku/modules/review/review_view.dart';
import 'package:otraku/modules/review/reviews_view.dart';
import 'package:otraku/modules/settings/settings_view.dart';
import 'package:otraku/modules/social/social_view.dart';
import 'package:otraku/modules/staff/staff_view.dart';
import 'package:otraku/modules/statistics/statistics_view.dart';
import 'package:otraku/modules/studio/studio_view.dart';
import 'package:otraku/modules/user/user_providers.dart';
import 'package:otraku/modules/user/user_view.dart';

List<GoRoute> buildRoutes(bool Function() shoudConfirmExit) {
  final FutureOr<bool> Function(BuildContext) onExit = (BuildContext context) {
    if (!shoudConfirmExit()) return true;
    return showPopUp<bool>(
      context,
      ConfirmationDialog(
        title: 'Exit?',
        mainAction: 'Yes',
        secondaryAction: 'No',
        onConfirm: () => Navigator.of(context).pop(true),
      ),
    ).then((value) => value ?? false);
  };

  return [
    GoRoute(
      path: '/404',
      builder: (context, state) => const _NotFound(),
    ),
    GoRoute(
      path: '/auth',
      onExit: onExit,
      builder: (context, state) {
        final fragment = state.uri.fragment;
        if (fragment.isEmpty) return const AuthView();

        final start = fragment.indexOf('=') + 1;
        final middle = fragment.indexOf('&');
        final end = fragment.lastIndexOf('=') + 1;

        final token = fragment.substring(start, middle);
        final expiration = int.tryParse(fragment.substring(end)) ?? -1;
        if (token.isEmpty || expiration < 0) return const AuthView();

        return AuthView((token, expiration));
      },
    ),
    GoRoute(
      path: '/home',
      onExit: onExit,
      builder: (context, state) {
        final tab = state.uri.queryParameters['tab'];
        return tab != null
            ? HomeView(tab: HomeTab.values.byName(tab))
            : const HomeView();
      },
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsView(),
    ),
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationsView(),
    ),
    GoRoute(
      path: '/calendar',
      builder: (context, state) => const CalendarView(),
    ),
    GoRoute(
      path: '/media/:id',
      redirect: _parseIdOr404,
      builder: (context, state) => MediaView(
        int.parse(state.pathParameters['id']!),
        state.uri.queryParameters['image'],
      ),
    ),
    GoRoute(
      path: '/character/:id',
      redirect: _parseIdOr404,
      builder: (context, state) => CharacterView(
        int.parse(state.pathParameters['id']!),
        state.uri.queryParameters['image'],
      ),
    ),
    GoRoute(
      path: '/staff/:id',
      redirect: _parseIdOr404,
      builder: (context, state) => StaffView(
        int.parse(state.pathParameters['id']!),
        state.uri.queryParameters['image'],
      ),
    ),
    GoRoute(
      path: '/user/:idOrName',
      builder: (context, state) {
        final param = state.pathParameters['idOrName']!;
        final id = int.tryParse(param);
        final tag = id != null ? idUserTag(id) : nameUserTag(param);
        return UserView(tag, state.uri.queryParameters['image']);
      },
    ),
    GoRoute(
      path: '/studio/:id',
      redirect: _parseIdOr404,
      builder: (context, state) => StudioView(
        int.parse(state.pathParameters['id']!),
        state.uri.queryParameters['name'],
      ),
    ),
    GoRoute(
      path: '/review/:id',
      redirect: _parseIdOr404,
      builder: (context, state) => ReviewView(
        int.parse(state.pathParameters['id']!),
        state.uri.queryParameters['image'],
      ),
    ),
    GoRoute(
      path: '/activity/:id',
      redirect: _parseIdOr404,
      builder: (context, state) => ActivityView(
        int.parse(state.pathParameters['id']!),
        state.uri.queryParameters['feedId'] != null
            ? int.parse(state.uri.queryParameters['feedId']!)
            : null,
      ),
    ),
    GoRoute(
      path: '/collection/anime/:id',
      redirect: _parseIdOr404,
      builder: (context, state) => CollectionView(
        int.parse(state.pathParameters['id']!),
        true,
      ),
    ),
    GoRoute(
      path: '/collection/manga/:id',
      redirect: _parseIdOr404,
      builder: (context, state) => CollectionView(
        int.parse(state.pathParameters['id']!),
        false,
      ),
    ),
    GoRoute(
      path: '/activities/:id',
      redirect: _parseIdOr404,
      builder: (context, state) => ActivitiesView(
        int.parse(state.pathParameters['id']!),
      ),
    ),
    GoRoute(
      path: '/favorites/:id',
      redirect: _parseIdOr404,
      builder: (context, state) => FavoritesView(
        int.parse(state.pathParameters['id']!),
      ),
    ),
    GoRoute(
      path: '/social/:id',
      redirect: _parseIdOr404,
      builder: (context, state) => SocialView(
        int.parse(state.pathParameters['id']!),
      ),
    ),
    GoRoute(
      path: '/reviews/:id',
      redirect: _parseIdOr404,
      builder: (context, state) => ReviewsView(
        int.parse(state.pathParameters['id']!),
      ),
    ),
    GoRoute(
      path: '/statistics/:id',
      redirect: _parseIdOr404,
      builder: (context, state) => StatisticsView(
        int.parse(state.pathParameters['id']!),
      ),
    ),
    GoRoute(
      path: '/anime/:id',
      redirect: (context, state) => '/media/${state.pathParameters['id']}',
    ),
    GoRoute(
      path: '/manga/:id',
      redirect: (context, state) => '/media/${state.pathParameters['id']}',
    ),
  ];
}

class Routes {
  const Routes._();

  static const notFound = '/404';

  static const auth = '/auth';

  static const settings = '/settings';

  static const notifications = '/notifications';

  static const calendar = '/calendar';

  static String home([HomeTab? tab]) =>
      '/home${tab != null ? "?tab=${tab.name}" : ""}';

  static String media(int id, [String? image]) =>
      '/media/$id${image != null ? "?image=$image" : ""}';

  static String character(int id, [String? image]) =>
      '/character/$id${image != null ? "?image=$image" : ""}';

  static String staff(int id, [String? image]) =>
      '/staff/$id${image != null ? "?image=$image" : ""}';

  static String user(int id, [String? image]) =>
      '/user/$id${image != null ? "?image=$image" : ""}';

  static String userByName(String name, [String? image]) =>
      '/user/$name${image != null ? "?image=$image" : ""}';

  static String studio(int id, [String? name]) =>
      '/studio/$id${name != null ? "?name=$name" : ""}';

  static String review(int id, [String? image]) =>
      '/review/$id${image != null ? "?image=$image" : ""}';

  static String activity(int id, [int? feedId]) =>
      '/activity/$id${feedId != null ? "?feedId=$feedId" : ""}';

  static String thread(int id) => '/thread/$id';

  static String animeCollection(int id) => '/collection/anime/$id';

  static String mangaCollection(int id) => '/collection/manga/$id';

  static String activities(int id) => '/activities/$id';

  static String favorites(int id) => '/favorites/$id';

  static String social(int id) => '/social/$id';

  static String reviews(int id) => '/reviews/$id';

  static String statistics(int id) => '/statistics/$id';
}

String? _parseIdOr404(BuildContext _, GoRouterState state) =>
    int.tryParse(state.pathParameters['id'] ?? '') == null ? '404' : null;

class _NotFound extends StatelessWidget {
  const _NotFound();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Text(
          '404 Not Found',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }
}
