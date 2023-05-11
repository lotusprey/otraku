import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/modules/home/home_provider.dart';
import 'package:otraku/common/utils/background_handler.dart';
import 'package:otraku/common/utils/route_arg.dart';
import 'package:otraku/common/utils/options.dart';
import 'package:otraku/common/utils/theming.dart';

Future<void> main() async {
  await Options.init();
  BackgroundHandler.init();
  runApp(const ProviderScope(child: App()));
}

class App extends StatefulWidget {
  const App();

  @override
  AppState createState() => AppState();
}

class AppState extends State<App> {
  @override
  void initState() {
    super.initState();
    Options().addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    Options().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    return Consumer(
      builder: (context, ref, _) => DynamicColorBuilder(
        builder: (lightDynamic, darkDynamic) {
          ColorScheme lightScheme;
          ColorScheme darkScheme;
          var theme = Options().theme;

          /// The system schemes must be cached, so
          /// they can later be used in the settings.
          final notifier = ref.watch(homeProvider.notifier);
          final hasDynamic = lightDynamic != null && darkDynamic != null;

          final darkBackground =
              Options().pureBlackDarkTheme ? Colors.black : null;

          if (hasDynamic) {
            lightDynamic = lightDynamic.harmonized();
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
            lightScheme = seed.scheme(Brightness.light);
            darkScheme = seed
                .scheme(Brightness.dark)
                .copyWith(background: darkBackground);
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

          SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarBrightness: scheme.brightness,
            statusBarIconBrightness: overlayBrightness,
            systemNavigationBarColor: Colors.transparent,
            systemNavigationBarIconBrightness: overlayBrightness,
          ));
          final data = themeDataFrom(scheme);

          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Otraku',
            theme: data,
            darkTheme: data,
            navigatorKey: RouteArg.navKey,
            onGenerateRoute: RouteArg.generateRoute,
            builder: (context, child) {
              /// Override the [textScaleFactor], because some devices apply
              /// too high of a factor and it breaks the app visually.
              /// [child] can't be null, because [onGenerateRoute] is provided.
              final mediaQuery = MediaQuery.of(context);
              final scale = mediaQuery.textScaleFactor.clamp(0.8, 1).toDouble();

              return MediaQuery(
                data: mediaQuery.copyWith(textScaleFactor: scale),
                child: child!,
              );
            },
          );
        },
      ),
    );
  }
}
