import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otraku/controllers/collection.dart';
import 'package:otraku/controllers/user.dart';
import 'package:otraku/controllers/user_settings.dart';
import 'package:otraku/pages/auth_page.dart';
import 'package:otraku/pages/tab_manager.dart';
import 'package:otraku/controllers/explorer.dart';
import 'package:otraku/services/graph_ql.dart';
import 'package:otraku/services/config.dart';
import 'package:otraku/tools/loader.dart';

class LoadingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Config.init(context);

    GraphQl.logIn().then((loggedIn) {
      if (!loggedIn)
        Get.offAll(AuthPage());
      else
        GraphQl.initViewerId().then((_) {
          Get.put(Collection(null, true), tag: Collection.ANIME).fetch();
          Get.put(Collection(null, false), tag: Collection.MANGA).fetch();
          Get.put(User(), tag: GraphQl.viewerId.toString()).fetchUser(null);
          Get.put(Explorer(), tag: '').fetchInitial();
          Get.put(UserSettings(), tag: '').fetchSettings();

          Get.offAll(TabManager());
        });
    });

    return Scaffold(body: const Center(child: Loader()));
  }
}
