import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ScrollxController extends GetxController {
  final scrollCtrl = ScrollController();

  void scrollTo(double offset) {
    if (!scrollCtrl.hasClients) return;
    if (scrollCtrl.offset > offset + 100) scrollCtrl.jumpTo(offset + 100);
    scrollCtrl.animateTo(
      offset,
      duration: const Duration(milliseconds: 200),
      curve: Curves.decelerate,
    );
  }

  @override
  void onClose() {
    scrollCtrl.dispose();
    super.onClose();
  }
}
