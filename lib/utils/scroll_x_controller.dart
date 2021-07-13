import 'package:flutter/material.dart';
import 'package:get/get.dart';

abstract class ScrollxController extends GetxController {
  final scrollCtrl = _ScrollController();

  Future<void> scrollTo(double offset) async {
    if (!scrollCtrl.hasClients) return;

    if (scrollCtrl.last.pixels > offset + 100)
      scrollCtrl.last.jumpTo(offset + 100);

    await scrollCtrl.last.animateTo(
      offset,
      duration: const Duration(milliseconds: 200),
      curve: Curves.decelerate,
    );
  }

  bool get hasNextPage;

  Future<void> fetchPage();

  bool _canLoad = true;

  Future<void> _listener() async {
    if (scrollCtrl.last.pixels > scrollCtrl.last.maxScrollExtent - 100 &&
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

class _ScrollController extends ScrollController {
  // Returns the last attached ScrollPosition.
  // This was necessary, because it's possible that there would be multiple
  // pages using the same Get controller and consecutively, using the same
  // ScrollController. The position getter works with only 1 ScrollPosition
  // attached, so that required the addition of lastPosition.
  ScrollPosition get last {
    assert(
      positions.isNotEmpty,
      'ScrollController not attached to any scroll views.',
    );
    return positions.last;
  }
}
