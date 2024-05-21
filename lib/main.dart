import 'dart:async';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:otraku/modules/viewer/api.dart';
import 'package:otraku/common/utils/routing.dart';
import 'package:otraku/modules/home/home_provider.dart';
import 'package:otraku/common/utils/background_handler.dart';
import 'package:otraku/common/utils/options.dart';
import 'package:otraku/common/utils/theming.dart';

Future<void> main() async {
  await Persistence.init();
  await Api.init();
  BackgroundHandler.init(_notificationCtrl);
  runApp(const ProviderScope(child: App()));
}

final _notificationCtrl = StreamController<String>.broadcast();

class App extends ConsumerStatefulWidget {
  const App();

  @override
  AppState createState() => AppState();
}

class AppState extends ConsumerState<App> {
  late final GoRouter _router;
  late final StreamSubscription<String> _notificationSubscription;

  @override
  void initState() {
    super.initState();
    _router = GoRouter(
      initialLocation: Api.hasActiveAccount() ? Routes.home() : Routes.auth,
      routes: buildRoutes(() => Persistence().confirmExit),
      errorBuilder: (context, state) => const NotFoundView(canPop: false),
    );

    if (Persistence().lastVersionCode != versionCode) {
      Persistence().updateVersionCodeToLatestVersion();
      BackgroundHandler.requestPermissionForNotifications();
    }

    Persistence().addListener(() => setState(() {}));
    _notificationSubscription = _notificationCtrl.stream.listen(_router.push);
  }

  @override
  void dispose() {
    _notificationSubscription.cancel();
    Persistence().dispose();
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

        Color? lightBackground;
        Color? darkBackground;
        if (Persistence().pureWhiteOrBlackTheme) {
          lightBackground = Colors.white;
          darkBackground = Colors.black;
        }

        Color lightSeed;
        Color darkSeed;
        var theme = Persistence().theme;

        if (theme == null &&
            systemLightPrimaryColor != null &&
            systemDarkPrimaryColor != null) {
          lightSeed = systemLightPrimaryColor;
          darkSeed = systemDarkPrimaryColor;
        } else {
          theme ??= 0;
          if (theme >= colorSeeds.length) {
            theme = colorSeeds.length - 1;
          }

          lightSeed = colorSeeds.values.elementAt(theme);
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

        final themeMode = Persistence().themeMode;
        final platformBrightness = MediaQuery.platformBrightnessOf(context);

        final isDark = themeMode == ThemeMode.system
            ? platformBrightness == Brightness.dark
            : themeMode == ThemeMode.dark;

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
          theme: themeDataFrom(lightScheme),
          darkTheme: themeDataFrom(darkScheme),
          themeMode: themeMode,
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
