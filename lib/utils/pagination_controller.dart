import 'package:flutter/widgets.dart';

/// A [ScrollController] that can perform and action when
/// the bottom of the page is reached. Used for pagination.
class PaginationController extends ScrollController {
  PaginationController({required this.loadMore}) {
    addListener(_listener);
  }

  /// The callback to call, when the end of the page is reached.
  final void Function() loadMore;

  /// Keeps track of the last [position.maxScrollExtent].
  /// Used to ensure that when the end of the page is reached,
  /// only one call to [loadMore] is performed, at least until
  /// the bottom of the newly expanded page is reached.
  double _lastMaxExtent = 0;

  /// When the user reached the bottom, try loading more data.
  void _listener() {
    if (position.pixels < position.maxScrollExtent - 100) return;
    if (_lastMaxExtent == position.maxScrollExtent) return;

    _lastMaxExtent = position.maxScrollExtent;
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

// Scroll up to a certain offset with an animation.
extension ScrollCommand on ScrollController {
  Future<void> scrollUpTo(double offset) async {
    if (!hasClients || positions.last.pixels <= offset) return;

    if (positions.last.pixels > offset + 100)
      positions.last.jumpTo(offset + 100);

    await positions.last.animateTo(
      offset,
      duration: const Duration(milliseconds: 200),
      curve: Curves.decelerate,
    );
  }
}
