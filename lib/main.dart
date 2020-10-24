import 'package:flutter/material.dart';
import 'package:otraku/pages/loading_page.dart';
import 'package:otraku/providers/anime_collection.dart';
import 'package:otraku/providers/explorable.dart';
import 'package:otraku/providers/manga_collection.dart';
import 'package:otraku/providers/design.dart';
import 'package:otraku/providers/page_item.dart';
import 'package:otraku/providers/users.dart';
import 'package:provider/provider.dart';
import 'providers/media_item.dart';
import 'providers/auth.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Design.init();
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
        ProxyProvider<Auth, MediaItem>(
          update: (_, auth, __) => MediaItem(auth.headers),
        ),
        ProxyProvider<Auth, PageItem>(
          update: (_, auth, __) => PageItem(auth.headers),
        ),
        ChangeNotifierProxyProvider<Auth, Users>(
          create: (_) => Users(),
          update: (_, auth, users) =>
              users..init(auth.headers, auth.userSettings),
        ),
        ChangeNotifierProxyProvider2<Auth, Users, Explorable>(
          create: (_) => Explorable(),
          update: (_, auth, user, explorable) =>
              explorable..init(auth.headers, user.settings.displayAdultContent),
        ),
        ChangeNotifierProxyProvider2<Auth, Users, AnimeCollection>(
          create: (_) => AnimeCollection(),
          update: (_, auth, user, collection) => collection
            ..init(
              headers: auth.headers,
              userId: user.settings.userId,
              mediaListSort: user.settings.sort,
              hasSplitCompletedList: user.settings.splitCompletedAnime,
              scoreFormat: user.settings.scoreFormat,
            ),
        ),
        ChangeNotifierProxyProvider2<Auth, Users, MangaCollection>(
          create: (_) => MangaCollection(),
          update: (_, auth, user, collection) => collection
            ..init(
              headers: auth.headers,
              userId: user.settings.userId,
              mediaListSort: user.settings.sort,
              hasSplitCompletedList: user.settings.splitCompletedManga,
              scoreFormat: user.settings.scoreFormat,
            ),
        ),
        ChangeNotifierProvider<Design>(
          create: (_) => Design(),
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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Otraku',
      theme: Provider.of<Design>(context).theme,
      home: LoadingPage(),
    );
  }
}
