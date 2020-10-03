import 'package:flutter/material.dart';
import 'package:otraku/pages/loading_page.dart';
import 'package:otraku/providers/anime_collection.dart';
import 'package:otraku/providers/explorable.dart';
import 'package:otraku/providers/manga_collection.dart';
import 'package:otraku/providers/design.dart';
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
        ChangeNotifierProxyProvider<Auth, Explorable>(
          create: (_) => Explorable(),
          update: (_, auth, explorable) => explorable..init(auth.headers),
        ),
        ChangeNotifierProxyProvider<Auth, AnimeCollection>(
          create: (_) => AnimeCollection(),
          update: (_, auth, collection) => collection
            ..init(
              headers: auth.headers,
              userId: auth.userId,
              mediaListSort: auth.sort,
              hasSplitCompletedList: auth.hasSplitCompletedList(ofAnime: true),
              scoreFormat: auth.scoreFormat,
            ),
        ),
        ChangeNotifierProxyProvider<Auth, MangaCollection>(
          create: (_) => MangaCollection(),
          update: (_, auth, collection) => collection
            ..init(
              headers: auth.headers,
              userId: auth.userId,
              mediaListSort: auth.sort,
              hasSplitCompletedList: auth.hasSplitCompletedList(ofAnime: false),
              scoreFormat: auth.scoreFormat,
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
