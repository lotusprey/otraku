import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:otraku/routing/route_parser.dart';
import 'package:otraku/routing/navigation.dart';
import 'package:otraku/utils/background_handler.dart';
import 'package:otraku/utils/theming.dart';

Future<void> main() async {
  await GetStorage.init();
  BackgroundHandler.init();
  runApp(App());
}

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) => MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Otraku',
        theme: Theming.it.theme.themeData,
        routerDelegate: Navigation.it,
        routeInformationParser: const RouteParser(),
      );

  @override
  void initState() {
    super.initState();
    Theming.it.addListener(() => setState(() {}));
    WidgetsBinding.instance?.window.onPlatformBrightnessChanged =
        Theming.it.refresh;
  }

  @override
  void dispose() {
    Theming.it.dispose();
    Navigation.it.dispose();
    super.dispose();
  }
}
