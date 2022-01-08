import 'dart:async';

/// After [delay] time has passed, since the last
/// call to the [run] method, call [callback].
/// E.g. do a search query after the user stops typing.
class Debounce {
  Debounce(this.callback, [this.delay = const Duration(milliseconds: 600)]);

  final void Function() callback;
  final Duration delay;
  Timer? _timer;

  void run() {
    _timer?.cancel();
    _timer = Timer(delay, callback);
  }
}
