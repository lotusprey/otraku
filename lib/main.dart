import 'dart:async';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:otraku/feature/viewer/persistence_model.dart';
import 'package:otraku/feature/viewer/persistence_provider.dart';
import 'package:otraku/util/routes.dart';
import 'package:otraku/util/background_handler.dart';
import 'package:otraku/util/theming.dart';

Future<void> main() async {
  final container = ProviderContainer(retry: (retryCount, error) => null);
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
  Color? _systemLightPrimaryColor;
  Color? _systemDarkPrimaryColor;

  @override
  void initState() {
    super.initState();

    final mustConfirmExit = () => ref.read(persistenceProvider).options.confirmExit;

    _router = Routes.buildRouter(mustConfirmExit);

    _notificationSubscription = _notificationCtrl.stream.listen(_router.push);

    var appMeta = ref.read(persistenceProvider).appMeta;
    if (appMeta.lastAppVersion != appVersion) {
      appMeta = AppMeta(
        lastAppVersion: appVersion,
        lastNotificationId: appMeta.lastNotificationId,
        lastBackgroundJob: appMeta.lastBackgroundJob,
      );

      WidgetsBinding.instance.addPostFrameCallback(
        (_) => ref.read(persistenceProvider.notifier).setAppMeta(appMeta),
      );

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
    ref.watch(viewerIdProvider);
    final options = ref.watch(persistenceProvider.select((s) => s.options));
    final platformBrightness = MediaQuery.platformBrightnessOf(context);
    final viewSize = MediaQuery.sizeOf(context);

    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        Color lightSeed = (options.themeBase ?? ThemeBase.navy).seed;
        Color darkSeed = lightSeed;
        if (lightDynamic != null && darkDynamic != null) {
          _systemLightPrimaryColor = lightDynamic.primary;
          _systemDarkPrimaryColor = darkDynamic.primary;

          // The system primary colors must be cached,
          // so they can later be used in the settings.
          final notifier = ref.watch(persistenceProvider.notifier);

          // A provider can't be modified during build,
          // so it's done asynchronously as a workaround.
          Future(
            () => notifier.cacheSystemPrimaryColors((
              lightPrimaryColor: _systemLightPrimaryColor,
              darkPrimaryColor: _systemDarkPrimaryColor,
            )),
          );

          if (options.themeBase == null &&
              _systemLightPrimaryColor != null &&
              _systemDarkPrimaryColor != null) {
            lightSeed = _systemLightPrimaryColor!;
            darkSeed = _systemDarkPrimaryColor!;
          }
        }

        Color? lightBackground;
        Color? darkBackground;
        if (options.highContrast) {
          lightBackground = Colors.white;
          darkBackground = Colors.black;
        }

        final lightScheme = ColorScheme.fromSeed(
          seedColor: lightSeed,
          brightness: Brightness.light,
        ).copyWith(surface: lightBackground);
        final darkScheme = ColorScheme.fromSeed(
          seedColor: darkSeed,
          brightness: Brightness.dark,
        ).copyWith(surface: darkBackground);

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
          theme: Theming.generateThemeData(lightScheme),
          darkTheme: Theming.generateThemeData(darkScheme),
          themeMode: options.themeMode,
          routerConfig: _router,
          builder: (context, child) {
            final directionality = Directionality.of(context);

            final theming = Theming(
              formFactor:
                  viewSize.width < Theming.windowWidthMedium ? FormFactor.phone : FormFactor.tablet,
              rightButtonOrientation: options.buttonOrientation == ButtonOrientation.auto
                  ? directionality == TextDirection.ltr
                  : options.buttonOrientation == ButtonOrientation.right,
            );

            // Override the [textScaleFactor], because some devices apply
            // too high of a factor and it breaks the app visually.
            final mediaQuery = MediaQuery.of(context);
            final scale = mediaQuery.textScaler.clamp(
              minScaleFactor: 0.8,
              maxScaleFactor: 1,
            );

            return Theme(
              data: Theme.of(context).copyWith(extensions: [theming]),
              child: MediaQuery(
                data: mediaQuery.copyWith(textScaler: scale),
                child: child!,
              ),
            );
          },
        );
      },
    );
  }
}
