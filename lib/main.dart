import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/utils/background_handler.dart';
import 'package:otraku/utils/route_arg.dart';
import 'package:otraku/utils/settings.dart';
import 'package:otraku/utils/theming.dart';

Future<void> main() async {
  await Settings.init();
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
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Otraku',
        theme: Theming().data,
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

  @override
  void initState() {
    super.initState();
    Theming().addListener(() => setState(() {}));
    WidgetsBinding.instance.window.onPlatformBrightnessChanged =
        Theming().refresh;
  }

  @override
  void dispose() {
    Theming().dispose();
    super.dispose();
  }
}
