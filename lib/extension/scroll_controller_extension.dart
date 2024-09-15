import 'package:flutter/widgets.dart';

extension ScrollControllerExtension on ScrollController {
  /// Scroll to the top with an animation.
  Future<void> scrollToTop() async {
    if (!hasClients || positions.last.pixels <= 0) return;

    if (positions.last.pixels > 100) positions.last.jumpTo(100);

    await positions.last.animateTo(
      0,
      duration: const Duration(milliseconds: 200),
      curve: Curves.decelerate,
    );
  }
}
