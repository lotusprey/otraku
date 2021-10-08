import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';

// A Get controller that can fetch data on overscroll.
abstract class OverscrollController extends GetxController {
  final scrollCtrl = MultiScrollController();

  // Scroll up to a certain offset with an animation.
  Future<void> scrollUpTo(double offset) async {
    if (!scrollCtrl.hasClients || scrollCtrl.lastPos.pixels <= offset) return;

    if (scrollCtrl.lastPos.pixels > offset + 100)
      scrollCtrl.lastPos.jumpTo(offset + 100);

    await scrollCtrl.lastPos.animateTo(
      offset,
      duration: const Duration(milliseconds: 200),
      curve: Curves.decelerate,
    );
  }

  bool get hasNextPage;

  Future<void> fetchPage();

  bool _canLoad = true;

  Future<void> _listener() async {
    if (scrollCtrl.lastPos.userScrollDirection == ScrollDirection.reverse &&
        scrollCtrl.lastPos.pixels > scrollCtrl.lastPos.maxScrollExtent - 100 &&
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
    scrollCtrl.dispose();
    super.onClose();
  }
}

class MultiScrollController extends ScrollController {
  // Returns the last attached ScrollPosition.
  // This was necessary, because it's possible that there would be multiple
  // pages using the same OverscrollController and consecutively, using the same
  // ScrollController. The ScrollController position getter works with only 1
  // ScrollPosition attached, so that required the addition of the following
  // getter.
  ScrollPosition get lastPos {
    assert(
      positions.isNotEmpty,
      'ScrollController not attached to any scroll views.',
    );
    return positions.last;
  }

  // Used to determine if this has been disposed.
  bool get mounted => _mounted;

  bool _mounted = true;

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }
}
