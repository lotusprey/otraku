import 'package:flutter/material.dart';
import 'package:otraku/enums/auth_enum.dart';
import 'package:otraku/pages/auth_page.dart';
import 'package:otraku/pages/tab_manager.dart';
import 'package:otraku/providers/anime_collection.dart';
import 'package:otraku/providers/auth.dart';
import 'package:otraku/providers/explorable.dart';
import 'package:otraku/providers/manga_collection.dart';
import 'package:otraku/providers/users.dart';
import 'package:otraku/providers/view_config.dart';
import 'package:otraku/tools/blossom_loader.dart';
import 'package:provider/provider.dart';

class LoadingPage extends StatefulWidget {
  @override
  _LoadingPageState createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  bool _didChangeDependencies = false;

  Future<void> Function() _fetchAnimeCollection;
  Future<void> Function() _fetchMangaCollection;
  Future<void> Function() _fetchExplorableMedia;
  Future<void> Function() _fetchViewer;

  @override
  Widget build(BuildContext context) {
    return Consumer<Auth>(
      builder: (_, auth, child) => FutureBuilder(
        future: auth.status == null
            ? auth.validateAccessToken()
            : Future.delayed(const Duration(seconds: 0)),
        builder: (_, snapshotAuth) {
          if (snapshotAuth.connectionState == ConnectionState.waiting) {
            return child;
          }

          if (auth.status != AuthStatus.authorised) {
            return const AuthPage();
          }

          switch (ViewConfig.initialPage) {
            case TabManager.ANIME_LIST:
              _fetchAnimeCollection().then((_) => _goToTabManager());
              _fetchMangaCollection();
              _fetchExplorableMedia();
              _fetchViewer();
              break;
            case TabManager.MANGA_LIST:
              _fetchAnimeCollection();
              _fetchMangaCollection().then((_) => _goToTabManager());
              _fetchExplorableMedia();
              _fetchViewer();
              break;
            case TabManager.EXPLORE:
              _fetchAnimeCollection();
              _fetchMangaCollection();
              _fetchExplorableMedia().then((_) => _goToTabManager());
              _fetchViewer();
              break;
            case TabManager.PROFILE:
              _fetchAnimeCollection();
              _fetchMangaCollection();
              _fetchExplorableMedia();
              _fetchViewer().then((_) => _goToTabManager());
              break;
          }

          return child;
        },
      ),
      child: Scaffold(
        body: const Center(child: BlossomLoader()),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didChangeDependencies) {
      ViewConfig.init(context);

      _fetchAnimeCollection = () =>
          Provider.of<AnimeCollection>(context, listen: false).fetchData();
      _fetchMangaCollection = () =>
          Provider.of<MangaCollection>(context, listen: false).fetchData();
      _fetchExplorableMedia =
          () => Provider.of<Explorable>(context, listen: false).fetchInitial();
      _fetchViewer =
          () => Provider.of<Users>(context, listen: false).fetchViewer();

      _didChangeDependencies = true;
    }
  }

  void _goToTabManager() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => TabManager()),
    );
  }
}
