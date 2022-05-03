import 'package:flutter/widgets.dart';

class PaginationController {
  PaginationController._(this._reload, this._loadMore) {
    scrollCtrl.addListener(_listener);
  }

  factory PaginationController({
    required Future<void> Function() reload,
    required Future<void> Function() loadMore,
  }) =>
      PaginationController._(reload, loadMore);

  double _lastMaxExtent = 0;
  final Future<void> Function() _reload;
  final Future<void> Function() _loadMore;
  final scrollCtrl = ScrollController();

  Future<void> _listener() async {
    if (scrollCtrl.position.pixels < scrollCtrl.position.maxScrollExtent - 100)
      return;

    if (_lastMaxExtent == scrollCtrl.position.maxScrollExtent) return;

    _lastMaxExtent = scrollCtrl.position.maxScrollExtent;
    await _loadMore();
  }

  Future<void> refresh() async {
    _lastMaxExtent = 0;
    await _reload();
  }

  void dispose() => scrollCtrl.dispose();
}
