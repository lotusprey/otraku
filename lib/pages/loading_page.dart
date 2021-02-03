import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otraku/pages/auth_page.dart';
import 'package:otraku/pages/home/home_page.dart';
import 'package:otraku/helpers/network.dart';
import 'package:otraku/controllers/config.dart';
import 'package:otraku/tools/loader.dart';

class LoadingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Get.put(Config());

    Network.logIn().then((loggedIn) {
      if (!loggedIn)
        Get.offAll(AuthPage(), transition: Transition.fadeIn);
      else
        Network.initViewerId().then((ok) {
          if (ok) Get.offAll(HomePage(), transition: Transition.fadeIn);
        });
    });

    return Scaffold(body: const Center(child: Loader()));
  }
}
