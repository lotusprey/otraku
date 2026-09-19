import 'dart:async';

/// After [delay] time has passed, since the last [run] call, call [callback].
/// E.g. do a search query after the user stops typing.
class Debounce {
  Debounce({this.delay = const Duration(milliseconds: 600)});

  final Duration delay;

  Timer? _timer;

  void cancel() => _timer?.cancel();

  void run(void Function() callback) {
    _timer?.cancel();
    _timer = Timer(delay, callback);
  }
}
