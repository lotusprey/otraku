import 'dart:async';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:otraku/common/utils/api.dart';
import 'package:otraku/common/utils/background_handler.dart';
import 'package:otraku/common/utils/image_quality.dart';
import 'package:otraku/common/utils/options.dart';
import 'package:otraku/common/utils/routing.dart';
import 'package:otraku/common/utils/theming.dart';
import 'package:otraku/modules/home/home_provider.dart';

Future<void> main() async {
  await Options.init();
  refreshImageQuality();
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
      routes: buildRoutes(() => Options().confirmExit),
    );

    if (Options().lastVersionCode != versionCode) {
      Options().updateVersionCodeToLatestVersion();
      BackgroundHandler.requestPermissionForNotifications();
    }

    Options().addListener(() => setState(() {}));
    _notificationSubscription = _notificationCtrl.stream.listen(_router.push);
  }

  @override
  void dispose() {
    _notificationSubscription.cancel();
    Options().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        ColorScheme lightScheme;
        ColorScheme darkScheme;
        var theme = Options().theme;

        // The system schemes must be cached, so
        // they can later be used in the settings.
        final notifier = ref.watch(homeProvider.notifier);
        final hasDynamic = lightDynamic != null && darkDynamic != null;

        Color? lightBackground;
        Color? darkBackground;
        if (Options().pureWhiteOrBlackTheme) {
          lightBackground = Colors.white;
          darkBackground = Colors.black;
        }

        if (hasDynamic) {
          lightDynamic = lightDynamic.harmonized().copyWith(
                background: lightBackground,
              );
          darkDynamic = darkDynamic.harmonized().copyWith(
                background: darkBackground,
              );
          notifier.setSystemSchemes(lightDynamic, darkDynamic);
        } else {
          notifier.setSystemSchemes(null, null);
        }

        if (theme == null && hasDynamic) {
          lightScheme = lightDynamic!;
          darkScheme = darkDynamic!;
        } else {
          theme ??= 0;
          if (theme >= colorSeeds.length) {
            theme = colorSeeds.length - 1;
          }

          final seed = colorSeeds.values.elementAt(theme);
          lightScheme = seed.scheme(Brightness.light).copyWith(
                background: lightBackground,
              );
          darkScheme = seed.scheme(Brightness.dark).copyWith(
                background: darkBackground,
              );
        }

        final mode = Options().themeMode;
        final platformBrightness =
            View.of(context).platformDispatcher.platformBrightness;

        final isDark = mode == ThemeMode.system
            ? platformBrightness == Brightness.dark
            : mode == ThemeMode.dark;

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
        final data = themeDataFrom(scheme);

        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'Otraku',
          theme: data,
          darkTheme: data,
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
