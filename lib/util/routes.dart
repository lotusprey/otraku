import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:otraku/extension/iterable_extension.dart';
import 'package:otraku/feature/viewer/persistence_provider.dart';
import 'package:otraku/feature/viewer/repository_provider.dart';
import 'package:otraku/widget/layout/top_bar.dart';
import 'package:otraku/widget/dialogs.dart';
import 'package:otraku/feature/activity/activities_view.dart';
import 'package:otraku/feature/activity/activity_view.dart';
import 'package:otraku/feature/calendar/calendar_view.dart';
import 'package:otraku/feature/character/character_view.dart';
import 'package:otraku/feature/collection/collection_view.dart';
import 'package:otraku/feature/favorites/favorites_view.dart';
import 'package:otraku/feature/home/home_model.dart';
import 'package:otraku/feature/home/home_view.dart';
import 'package:otraku/feature/media/media_view.dart';
import 'package:otraku/feature/notification/notifications_view.dart';
import 'package:otraku/feature/review/review_view.dart';
import 'package:otraku/feature/review/reviews_view.dart';
import 'package:otraku/feature/settings/settings_view.dart';
import 'package:otraku/feature/social/social_view.dart';
import 'package:otraku/feature/staff/staff_view.dart';
import 'package:otraku/feature/statistics/statistics_view.dart';
import 'package:otraku/feature/studio/studio_view.dart';
import 'package:otraku/feature/user/user_providers.dart';
import 'package:otraku/feature/user/user_view.dart';
import 'package:otraku/widget/loaders.dart';

class Routes {
  const Routes._();

  static const notFound = '/404';

  static const settings = '/settings';

  static const notifications = '/notifications';

  static const calendar = '/calendar';

  static String home([HomeTab? tab]) =>
      '/home${tab != null ? "?tab=${tab.name}" : ""}';

  static String media(int id, [String? imageUrl]) =>
      '/media/$id${imageUrl != null ? "?image=$imageUrl" : ""}';

  static String character(int id, [String? imageUrl]) =>
      '/character/$id${imageUrl != null ? "?image=$imageUrl" : ""}';

  static String staff(int id, [String? imageUrl]) =>
      '/staff/$id${imageUrl != null ? "?image=$imageUrl" : ""}';

  static String user(int id, [String? imageUrl]) =>
      '/user/$id${imageUrl != null ? "?image=$imageUrl" : ""}';

  static String userByName(String name, [String? imageUrl]) =>
      '/user/$name${imageUrl != null ? "?image=$imageUrl" : ""}';

  static String studio(int id, [String? name]) =>
      '/studio/$id${name != null ? "?name=$name" : ""}';

  static String review(int id, [String? imageUrl]) =>
      '/review/$id${imageUrl != null ? "?image=$imageUrl" : ""}';

  static String activity(int id, [int? feedId]) =>
      '/activity/$id${feedId != null ? "?feedId=$feedId" : ""}';

  static String thread(int id) => '/thread/$id';

  static String comment(int id) => '/comment/$id';

  static String animeCollection(int id) => '/collection/anime/$id';

  static String mangaCollection(int id) => '/collection/manga/$id';

  static String activities(int id) => '/activities/$id';

  static String favorites(int id) => '/favorites/$id';

  static String social(int id) => '/social/$id';

  static String reviews(int id) => '/reviews/$id';

  static String statistics(int id) => '/statistics/$id';

  static GoRouter buildRouter(bool Function() mustConfirmExit) {
    final onExit = (BuildContext context, GoRouterState _) async {
      if (!mustConfirmExit()) return Future.value(true);

      var exit = false;
      await ConfirmationDialog.show(
        context,
        title: 'Exit?',
        primaryAction: 'Yes',
        secondaryAction: 'No',
        onConfirm: () => exit = true,
      );

      return exit;
    };

    final routes = [
      GoRoute(path: '/', redirect: (context, state) => '/home'),
      GoRoute(
        path: '/auth',
        builder: (context, state) {
          final fragment = state.uri.fragment;
          if (fragment.isEmpty) return const _AuthView(null);

          final start = fragment.indexOf('=') + 1;
          final middle = fragment.indexOf('&');
          final end = fragment.lastIndexOf('=') + 1;

          final token = fragment.substring(start, middle);
          final expiration = int.tryParse(fragment.substring(end)) ?? -1;
          if (token.isEmpty || expiration <= 0) return const _AuthView(null);

          return _AuthView((token, expiration));
        },
      ),
      GoRoute(
        path: '/404',
        builder: (context, state) => const NotFoundView(),
      ),
      GoRoute(
        path: '/home',
        onExit: onExit,
        redirect: (context, state) {
          final tabName = state.uri.queryParameters['tab'];
          if (tabName == null) return null;

          final tab = HomeTab.values.firstWhereOrNull((e) => e.name == tabName);
          return tab != null ? null : notFound;
        },
        builder: (context, state) {
          final tabName = state.uri.queryParameters['tab'];

          return HomeView(
            key: state.pageKey,
            tab: tabName != null ? HomeTab.values.byName(tabName) : null,
          );
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

      // Extra routes for AniList deep links:
      // - Media endpoints are split between anime/manga.
      // - Paths can contain superfluous information after the path parameter.
      GoRoute(
        path: '/anime/:id',
        redirect: (context, state) => '/media/${state.pathParameters['id']}',
      ),
      GoRoute(
        path: '/manga/:id',
        redirect: (context, state) => '/media/${state.pathParameters['id']}',
      ),
      GoRoute(
        path: '/anime/:id/:_(.*)',
        redirect: (context, state) => '/media/${state.pathParameters['id']}',
      ),
      GoRoute(
        path: '/manga/:id/:_(.*)',
        redirect: (context, state) => '/media/${state.pathParameters['id']}',
      ),
      GoRoute(
        path: '/character/:id/:_(.*)',
        redirect: (context, state) =>
            '/character/${state.pathParameters['id']}',
      ),
      GoRoute(
        path: '/staff/:id/:_(.*)',
        redirect: (context, state) => '/staff/${state.pathParameters['id']}',
      ),
      GoRoute(
        path: '/studio/:id/:_(.*)',
        redirect: (context, state) => '/studio/${state.pathParameters['id']}',
      ),
      GoRoute(
        path: '/user/:name/:_(.*)',
        redirect: (context, state) => '/user/${state.pathParameters['name']}',
      ),
    ];

    return GoRouter(
      routes: routes,
      initialLocation: Routes.home(),
      errorBuilder: (context, state) => const NotFoundView(),
    );
  }
}

String? _parseIdOr404(BuildContext context, GoRouterState state) =>
    int.tryParse(state.pathParameters['id'] ?? '') == null
        ? Routes.notFound
        : null;

class NotFoundView extends StatelessWidget {
  const NotFoundView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopBar(title: 'Not Found'),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '404 Not Found',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            TextButton(
              child: const Text('Go Home'),
              onPressed: () => context.go(Routes.home()),
            ),
          ],
        ),
      ),
    );
  }
}

class _AuthView extends ConsumerStatefulWidget {
  const _AuthView(this.credentials);

  final (String token, int secondsUntilExpiration)? credentials;

  @override
  ConsumerState<_AuthView> createState() => __AuthViewState();
}

class __AuthViewState extends ConsumerState<_AuthView> {
  @override
  void initState() {
    super.initState();

    if (widget.credentials == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await ConfirmationDialog.show(context, title: 'Invalid credentials');
        if (mounted) context.go(Routes.home());
      });
    }

    _attemptToFinishAccountSetup();
  }

  @override
  void didUpdateWidget(covariant _AuthView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.credentials?.$1 != oldWidget.credentials?.$1 ||
        widget.credentials?.$2 != oldWidget.credentials?.$2) {
      _attemptToFinishAccountSetup();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Authenticating, please wait...'),
            SizedBox(height: 20),
            Loader(),
          ],
        ),
      ),
    );
  }

  void _attemptToFinishAccountSetup() async {
    if (widget.credentials == null) {
      return;
    }

    final token = widget.credentials!.$1;
    final expiration = widget.credentials!.$2;

    final account = await ref
        .read(repositoryProvider.notifier)
        .initAccount(token, expiration);

    if (account == null) {
      if (mounted) {
        await ConfirmationDialog.show(
          context,
          title: 'Failed to connect account',
        );

        if (mounted) context.go(Routes.home());
      }

      return;
    }

    await ref.read(persistenceProvider.notifier).addAccount(account);
    if (mounted) context.go(Routes.home());
  }
}
