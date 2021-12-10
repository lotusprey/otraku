import 'package:flutter/material.dart';
import 'package:otraku/utils/route_arg.dart';
import 'package:otraku/utils/local_settings.dart';
import 'package:otraku/utils/theming.dart';

Future<void> main() async {
  await LocalSettings.init();
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
        theme: Theming().theme.themeData,
        navigatorKey: RouteArg.navKey,
        initialRoute: RouteArg.auth,
        onGenerateRoute: RouteArg.generateRoute,
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
