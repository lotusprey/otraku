import 'package:flutter/material.dart';
import 'package:otraku/utils/background_handler.dart';
import 'package:otraku/utils/route_arg.dart';
import 'package:otraku/utils/settings.dart';
import 'package:otraku/utils/theming.dart';

Future<void> main() async {
  await Settings.init();
  BackgroundHandler.init();
  runApp(App());
}

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Otraku',
        theme: Theming().theme,
        navigatorKey: RouteArg.navKey,
        onGenerateRoute: RouteArg.generateRoute,

        /// Configure default overscroll behaviour on Android. May become
        /// unnecessary in the future.
        ///
        /// Override the [textScaleFactor] as to not break the app visually.
        /// [child] shouldn't be null, because [onGenerateRoute] is provided.
        builder: (context, child) {
          final mediaQuery = MediaQuery.of(context);
          final scale = mediaQuery.textScaleFactor.clamp(0.8, 1).toDouble();

          return ScrollConfiguration(
            behavior: const ScrollBehavior(
              androidOverscrollIndicator: AndroidOverscrollIndicator.stretch,
            ),
            child: MediaQuery(
              data: mediaQuery.copyWith(textScaleFactor: scale),
              child: child!,
            ),
          );
        },
      );

  @override
  void initState() {
    super.initState();
    Theming().addListener(() => setState(() {}));
    WidgetsBinding.instance?.window.onPlatformBrightnessChanged =
        Theming().refresh;
  }

  @override
  void dispose() {
    Theming().dispose();
    super.dispose();
  }
}
