import 'dart:async';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/feature/viewer/repository_provider.dart';
import 'package:otraku/util/routes.dart';
import 'package:otraku/feature/home/home_provider.dart';
import 'package:otraku/util/background_handler.dart';
import 'package:otraku/util/persistence.dart';
import 'package:otraku/util/theming.dart';

Future<void> main() async {
  final container = ProviderContainer();
  await Persistence.init();
  await container.read(repositoryProvider.notifier).init();
  BackgroundHandler.init(_notificationCtrl);

  runApp(UncontrolledProviderScope(container: container, child: const App()));
}

final _notificationCtrl = StreamController<String>.broadcast();

class App extends ConsumerStatefulWidget {
  const App();

  @override
  AppState createState() => AppState();
}

class AppState extends ConsumerState<App> {
  final _router = Routes.buildRouter(Persistence());
  late final StreamSubscription<String> _notificationSubscription;

  @override
  void initState() {
    super.initState();
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
          if (theme >= Theming.colorSeeds.length) {
            theme = Theming.colorSeeds.length - 1;
          }

          lightSeed = Theming.colorSeeds.values.elementAt(theme);
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
          theme: Theming.schemeToThemeData(lightScheme),
          darkTheme: Theming.schemeToThemeData(darkScheme),
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
