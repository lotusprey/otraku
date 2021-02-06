import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ScrollxController extends GetxController {
  final _scrollCtrl = ScrollController();

  ScrollController get scrollCtrl => _scrollCtrl;

  void scrollToTop() => scrollTo(0);

  void scrollTo(double offset) {
    if (!_scrollCtrl.hasClients) return;
    if (_scrollCtrl.offset > offset + 100) _scrollCtrl.jumpTo(offset + 100);
    _scrollCtrl.animateTo(
      offset,
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
