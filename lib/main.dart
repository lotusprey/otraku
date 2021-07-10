import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:otraku/routing/route_parser.dart';
import 'package:otraku/routing/navigation.dart';
import 'package:otraku/utils/background_handler.dart';
import 'package:otraku/utils/config.dart';

Future<void> main() async {
  await GetStorage.init();
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    BackgroundHandler.init(context);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Otraku',
      theme: Config.theme,
      darkTheme: Config.theme,
      routerDelegate: Navigation.it,
      routeInformationParser: const RouteParser(),
    );
  }
}
