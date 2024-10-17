import 'dart:async';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:otraku/feature/viewer/persistence_model.dart';
import 'package:otraku/feature/viewer/persistence_provider.dart';
import 'package:otraku/util/routes.dart';
import 'package:otraku/feature/home/home_provider.dart';
import 'package:otraku/util/background_handler.dart';
import 'package:otraku/util/theming.dart';

Future<void> main() async {
  final container = ProviderContainer();
  await container.read(persistenceProvider.notifier).init();
  BackgroundHandler.init(_notificationCtrl);

  runApp(UncontrolledProviderScope(container: container, child: const _App()));
}

final _notificationCtrl = StreamController<String>.broadcast();

class _App extends ConsumerStatefulWidget {
  const _App();

  @override
  AppState createState() => AppState();
}

class AppState extends ConsumerState<_App> {
  late final GoRouter _router;
  late final StreamSubscription<String> _notificationSubscription;

  @override
  void initState() {
    super.initState();

    final isGuest = ref.read(persistenceProvider.select(
      (s) => s.accountGroup.accountIndex == null,
    ));

    final mustConfirmExit = () => ref.read(persistenceProvider.select(
          (s) => s.options.confirmExit,
        ));

    _router = Routes.buildRouter(isGuest, mustConfirmExit);

    _notificationSubscription = _notificationCtrl.stream.listen(_router.push);

    var appMeta = ref.read(persistenceProvider).appMeta;
    if (appMeta.lastAppVersion != appVersion) {
      appMeta = AppMeta(
        lastAppVersion: appVersion,
        lastNotificationId: appMeta.lastNotificationId,
        lastBackgroundJob: appMeta.lastBackgroundJob,
      );
      ref.read(persistenceProvider.notifier).setAppMeta(appMeta);

      BackgroundHandler.requestPermissionForNotifications();
    }
  }

  @override
  void dispose() {
    _notificationSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        Color? systemLightPrimaryColor = lightDynamic?.primary;
        Color? systemDarkPrimaryColor = darkDynamic?.primary;

        // The system schemes must be cached, so
        // they can later be used in the settings.
        final notifier = ref.watch(homeProvider.notifier);
        Future(
          () => notifier.cacheSystemColorSchemes(
            systemLightPrimaryColor,
            systemDarkPrimaryColor,
          ),
        );

        final options = ref.watch(persistenceProvider.select((s) => s.options));

        Color? lightBackground;
        Color? darkBackground;
        if (options.highContrast) {
          lightBackground = Colors.white;
          darkBackground = Colors.black;
        }

        Color lightSeed;
        Color darkSeed;

        if (options.themeBase == null &&
            systemLightPrimaryColor != null &&
            systemDarkPrimaryColor != null) {
          lightSeed = systemLightPrimaryColor;
          darkSeed = systemDarkPrimaryColor;
        } else {
          lightSeed = (options.themeBase ?? ThemeBase.navy).seed;
          darkSeed = lightSeed;
        }

        final lightScheme = ColorScheme.fromSeed(
          seedColor: lightSeed,
          brightness: Brightness.light,
        ).copyWith(surface: lightBackground);
        final darkScheme = ColorScheme.fromSeed(
          seedColor: darkSeed,
          brightness: Brightness.dark,
        ).copyWith(surface: darkBackground);

        final platformBrightness = MediaQuery.platformBrightnessOf(context);

        final isDark = options.themeMode == ThemeMode.system
            ? platformBrightness == Brightness.dark
            : options.themeMode == ThemeMode.dark;

        final ColorScheme scheme;
        final Brightness overlayBrightness;
        if (isDark) {
          scheme = darkScheme;
          overlayBrightness = Brightness.light;
        } else {
          scheme = lightScheme;
          overlayBrightness = Brightness.dark;
        }

        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarBrightness: scheme.brightness,
          statusBarIconBrightness: overlayBrightness,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarContrastEnforced: false,
          systemNavigationBarIconBrightness: overlayBrightness,
        ));

        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'Otraku',
          theme: Theming.schemeToThemeData(lightScheme),
          darkTheme: Theming.schemeToThemeData(darkScheme),
          themeMode: options.themeMode,
          routerConfig: _router,
          builder: (context, child) {
            // Override the [textScaleFactor], because some devices apply
            // too high of a factor and it breaks the app visually.
            // [child] can't be null, because [onGenerateRoute] is provided.
            final mediaQuery = MediaQuery.of(context);
            final scale = mediaQuery.textScaler.clamp(
              minScaleFactor: 0.8,
              maxScaleFactor: 1,
            );

            return MediaQuery(
              data: mediaQuery.copyWith(textScaler: scale),
              child: child!,
            );
          },
        );
      },
    );
  }
}
