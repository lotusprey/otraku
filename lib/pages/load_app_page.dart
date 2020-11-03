import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otraku/pages/auth_page.dart';
import 'package:otraku/pages/tab_manager.dart';
import 'package:otraku/providers/collections.dart';
import 'package:otraku/providers/explorable.dart';
import 'package:otraku/providers/network_service.dart';
import 'package:otraku/providers/users.dart';
import 'package:otraku/providers/app_config.dart';
import 'package:otraku/tools/blossom_loader.dart';
import 'package:provider/provider.dart';

class LoadAppPage extends StatefulWidget {
  @override
  _LoadAppPageState createState() => _LoadAppPageState();
}

class _LoadAppPageState extends State<LoadAppPage> {
  @override
  Widget build(BuildContext context) {
    NetworkService.logIn().then((loggedIn) {
      if (!loggedIn) {
        Get.offAll(AuthPage());
        return;
      }

      AppConfig.init(context);

      final Future<void> Function() fetchAnimeCollection =
          Provider.of<Collections>(context, listen: false).fetchMyAnime;
      final Future<void> Function() fetchMangaCollection =
          Provider.of<Collections>(context, listen: false).fetchMyManga;
      final Future<void> Function() fetchExplorableMedia =
          Provider.of<Explorable>(context, listen: false).fetchInitial;
      final Future<void> Function() fetchViewer =
          Provider.of<Users>(context, listen: false).fetchViewer;

      NetworkService.initViewerId().then((_) {
        switch (AppConfig.pageIndex.value) {
          case TabManager.ANIME_LIST:
            fetchAnimeCollection().then((_) => _goToTabManager());
            fetchMangaCollection();
            fetchExplorableMedia();
            fetchViewer();
            break;
          case TabManager.MANGA_LIST:
            fetchAnimeCollection();
            fetchMangaCollection().then((_) => _goToTabManager());
            fetchExplorableMedia();
            fetchViewer();
            break;
          case TabManager.EXPLORE:
            fetchAnimeCollection();
            fetchMangaCollection();
            fetchExplorableMedia().then((_) => _goToTabManager());
            fetchViewer();
            break;
          case TabManager.PROFILE:
            fetchAnimeCollection();
            fetchMangaCollection();
            fetchExplorableMedia();
            fetchViewer().then((_) => _goToTabManager());
            break;
        }
      });
    });

    return Scaffold(
      body: const Center(child: BlossomLoader()),
    );
  }

  void _goToTabManager() => Get.offAll(TabManager());
}
