import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otraku/pages/auth_page.dart';
import 'package:otraku/pages/tab_manager.dart';
import 'package:otraku/controllers/collections.dart';
import 'package:otraku/controllers/explorer.dart';
import 'package:otraku/controllers/network_service.dart';
import 'package:otraku/controllers/users.dart';
import 'package:otraku/controllers/config.dart';
import 'package:otraku/tools/loader.dart';

class LoadingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    NetworkService.logIn().then((loggedIn) {
      if (!loggedIn) {
        Get.offAll(AuthPage());
        return;
      }

      Config.init(context);

      final Future<void> Function() fetchAnimeCollection =
          Get.find<Collections>().fetchMyAnime;
      final Future<void> Function() fetchMangaCollection =
          Get.find<Collections>().fetchMyManga;
      final Future<void> Function() fetchExplorableMedia =
          Get.find<Explorer>().fetchInitial;
      final Future<void> Function() fetchViewer = Get.find<Users>().fetchViewer;

      NetworkService.initViewerId().then((_) {
        switch (Config.pageIndex) {
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
      body: const Center(child: Loader()),
    );
  }

  void _goToTabManager() => Get.offAll(TabManager());
}
