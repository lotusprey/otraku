import 'package:flutter/material.dart';
import 'package:get/get.dart';

abstract class ScrollxController extends GetxController {
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

  bool get hasNextPage;

  Future<void> fetchPage();

  bool _canLoad = true;

  Future<void> _listener() async {
    if (scrollCtrl.position.pixels >
            scrollCtrl.position.maxScrollExtent - 100 &&
        hasNextPage &&
        _canLoad) {
      _canLoad = false;
      await fetchPage();
      _canLoad = true;
    }
  }

  @override
  void onInit() {
    super.onInit();
    scrollCtrl.addListener(_listener);
  }

  @override
  void onClose() {
    scrollCtrl.removeListener(_listener);
    scrollCtrl.dispose();
    super.onClose();
  }
}
