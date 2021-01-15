import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ScrollableController extends GetxController {
  final _scrollCtrl = ScrollController();

  ScrollController get scrollCtrl => _scrollCtrl;

  void scrollToTop() {
    if (!_scrollCtrl.hasClients) return;
    if (_scrollCtrl.offset > 100) _scrollCtrl.jumpTo(100);
    _scrollCtrl.animateTo(
      0,
      duration: const Duration(milliseconds: 200),
      curve: Curves.decelerate,
    );
  }

  @override
  void onClose() {
    _scrollCtrl.dispose();
    super.onClose();
  }
}
