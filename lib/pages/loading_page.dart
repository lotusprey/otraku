import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otraku/controllers/user.dart';
import 'package:otraku/controllers/user_settings.dart';
import 'package:otraku/pages/auth_page.dart';
import 'package:otraku/pages/tab_manager.dart';
import 'package:otraku/controllers/collections.dart';
import 'package:otraku/controllers/explorer.dart';
import 'package:otraku/controllers/network_service.dart';
import 'package:otraku/controllers/config.dart';
import 'package:otraku/tools/loader.dart';

class LoadingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Config.init(context);

    NetworkService.logIn().then((loggedIn) {
      if (!loggedIn)
        Get.offAll(AuthPage());
      else
        NetworkService.initViewerId().then((_) {
          Get.put(Collections())
            ..fetchMyAnime()
            ..fetchMyManga();
          Get.put(Explorer()).fetchInitial();
          Get.put(User(), tag: User.ME).fetchUser(null);
          Get.put(UserSettings()).fetchSettings();

          Get.offAll(TabManager());
        });
    });

    return Scaffold(body: const Center(child: Loader()));
  }
}
