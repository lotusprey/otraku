import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';

/// To be deprecated.
/// A [GetxController] that can fetch data on overscroll.
abstract class ScrollingController extends GetxController {
  final scrollCtrl = MultiScrollController();

  Future<void> fetchPage() => Future.value();

  bool _canLoad = true;

  Future<void> _listener() async {
    if (scrollCtrl.pos.userScrollDirection == ScrollDirection.reverse &&
        scrollCtrl.pos.pixels > scrollCtrl.pos.maxScrollExtent - 100 &&
        _canLoad) {
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

// To be deprecated.
class MultiScrollController extends ScrollController {
  // Returns the last attached ScrollPosition.
  // This was necessary, because it's possible that there would be multiple
  // views using the same ScrollingController and consecutively, using the same
  // ScrollController. The ScrollController position getter works with only 1
  // ScrollPosition attached, so that required the addition of the following
  // getter.
  ScrollPosition get pos {
    assert(
      positions.isNotEmpty,
      'ScrollController not attached to any scroll views.',
    );
    return positions.last;
  }

  bool _mounted = true;

  @override
  void removeListener(VoidCallback listener) {
    if (_mounted) super.removeListener(listener);
  }

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }
}
