import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:otraku/enums/theme_enum.dart';
import 'package:otraku/pages/loading_page.dart';
import 'package:otraku/providers/collections.dart';
import 'package:otraku/providers/explorable.dart';
import 'package:otraku/providers/users.dart';
import 'package:provider/provider.dart';
import 'providers/auth.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  runApp(Otraku());
}

class Otraku extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<Auth>(
          create: (_) => Auth(),
        ),
        ChangeNotifierProxyProvider<Auth, Collections>(
          create: (_) => Collections(),
          update: (_, auth, collections) => collections..init(auth.viewerId),
        ),
        ChangeNotifierProvider<Users>(
          create: (_) => Users(),
        ),
        ChangeNotifierProvider<Explorable>(
          create: (_) => Explorable(),
        ),
      ],
      child: const App(),
    );
  }
}

class App extends StatelessWidget {
  const App({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeIndex = GetStorage().read('theme') ?? 0;

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Otraku',
      theme: Themes.values[themeIndex].themeData,
      home: LoadingPage(),
    );
  }
}
