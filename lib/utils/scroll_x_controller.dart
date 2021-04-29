import 'package:flutter/material.dart';
import 'package:get/get.dart';

abstract class ScrollxController extends GetxController {
  final scrollCtrl = ScrollController();

  Future<void> scrollTo(double offset) async {
    if (!scrollCtrl.hasClients) return;
    if (scrollCtrl.offset > offset + 100) scrollCtrl.jumpTo(offset + 100);
    await scrollCtrl.animateTo(
      offset,
      duration: const Duration(milliseconds: 200),
      curve: Curves.decelerate,
    );
  }

  bool get hasNextPage;

  Future<void> fetchPage();

  bool _canLoad = true;

  Future<void> _listener() async {
    if (scrollCtrl.offset > scrollCtrl.position.maxScrollExtent - 100 &&
        _canLoad &&
        hasNextPage) {
      _canLoad = false;
      await fetchPage();
      await Future.delayed(const Duration(seconds: 1));
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
