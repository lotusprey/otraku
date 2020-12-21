import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:otraku/pages/loading_page.dart';
import 'package:otraku/controllers/config.dart';

Future<void> main() async {
  await GetStorage.init();
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Config.updateTheme();
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Otraku',
      home: LoadingPage(),
      defaultTransition: Platform.isIOS || Platform.isMacOS
          ? Transition.native
          : Transition.downToUp,
    );
  }
}
