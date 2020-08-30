import 'package:flutter/material.dart';
import 'package:otraku/providers/explorable_media.dart';
import 'package:otraku/providers/manga_collection.dart';
import 'package:otraku/providers/theming.dart';
import 'package:otraku/providers/view_config.dart';
import 'package:otraku/tools/wave_bar_loader.dart';
import 'package:provider/provider.dart';
import 'enums/auth_enum.dart';
import 'pages/auth_page.dart';
import 'pages/tab_manager.dart';
import 'providers/media_item.dart';
import 'providers/auth.dart';
import 'providers/anime_collection.dart';

void main() {
  Provider.debugCheckInvalidValueType = null;

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<Auth>(
          create: (_) => Auth(),
        ),
        ProxyProvider<Auth, MediaItem>(
          update: (_, auth, __) => MediaItem(auth.accessToken),
        ),
        ProxyProvider<Auth, AnimeCollection>(
          update: (_, auth, __) => AnimeCollection(
            accessToken: auth.accessToken,
            userId: auth.userId,
            scoreFormat: auth.scoreFormat,
          ),
        ),
        ProxyProvider<Auth, MangaCollection>(
          update: (_, auth, __) => MangaCollection(
            accessToken: auth.accessToken,
            userId: auth.userId,
            scoreFormat: auth.scoreFormat,
          ),
        ),
        ProxyProvider<Auth, ExplorableMedia>(
          update: (_, auth, __) => ExplorableMedia(auth.accessToken),
        ),
        ChangeNotifierProvider<ViewConfig>(
          create: (_) => ViewConfig(),
        ),
        ChangeNotifierProvider<Theming>(
          create: (_) => Theming(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Otraku',
        theme: ThemeData(
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
          fontFamily: 'Rubik',
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: Consumer<Theming>(
          builder: (_, theming, childTheme) => FutureBuilder(
            future: theming.palette == null
                ? theming.init()
                : Future.delayed(const Duration(seconds: 0)),
            builder: (_, snapshotTheme) {
              if (snapshotTheme.connectionState == ConnectionState.waiting) {
                return childTheme;
              }

              return Consumer<Auth>(
                builder: (_, auth, childAuth) => FutureBuilder(
                  future: auth.status == null
                      ? auth.validateAccessToken()
                      : Future.delayed(const Duration(seconds: 0)),
                  builder: (_, snapshotAuth) {
                    if (snapshotAuth.connectionState ==
                        ConnectionState.waiting) {
                      return childAuth;
                    }

                    if (auth.status != AuthStatus.authorised) {
                      return const AuthPage();
                    }

                    return const TabManager();
                  },
                ),
                child: Scaffold(
                  backgroundColor: theming.palette.background,
                  body: const Center(child: WaveBarLoader()),
                ),
              );
            },
          ),
          child: const Scaffold(
            backgroundColor: Colors.black,
          ),
        ),
      ),
    );
  }
}
