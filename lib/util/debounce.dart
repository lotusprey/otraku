import 'dart:async';

/// After [_delay] time has passed, since the last [run] call, call [callback].
/// E.g. do a search query after the user stops typing.
class Debounce {
  static const _delay = Duration(milliseconds: 600);

  Timer? _timer;

  void cancel() => _timer?.cancel();

  void run(void Function() callback) {
    _timer?.cancel();
    _timer = Timer(_delay, callback);
  }
}
