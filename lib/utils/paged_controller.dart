import 'package:flutter/widgets.dart';

/// A [ScrollController] that can perform and action when
/// the bottom of the page is reached. Used for pagination.
class PagedController extends ScrollController {
  PagedController({required this.loadMore}) {
    addListener(_listener);
  }

  /// The callback to call, when the end of the page is reached.
  final void Function() loadMore;

  /// Keeps track of the last [position.maxScrollExtent].
  /// Used to ensure that when the end of the page is reached,
  /// only one call to [loadMore] is performed, at least until
  /// the bottom of the newly expanded page is reached.
  double _lastMaxExtent = 0;

  /// When the user reaches the bottom, try loading more data.
  void _listener() {
    final pos = positions.last;
    if (pos.pixels < pos.maxScrollExtent - 100) return;
    if (_lastMaxExtent == pos.maxScrollExtent) return;

    _lastMaxExtent = pos.maxScrollExtent;
    loadMore();
  }

  /// When a scrollable is detached, [_lastMaxExtent] needs to be reset, so
  /// that it would work properly, if the scrollable gets attached again.
  @override
  void detach(ScrollPosition position) {
    _lastMaxExtent = 0;
    super.detach(position);
  }
}

// Scroll up to the top with an animation.
extension ScrollCommand on ScrollController {
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
