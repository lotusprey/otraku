import 'dart:async';

import 'package:flutter/material.dart';
import 'package:otraku/common/utils/consts.dart';

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

class SearchField extends StatefulWidget {
  const SearchField({
    required this.value,
    required this.hint,
    required this.onChanged,
    this.focusNode,
    this.debounce,
  });

  final String value;
  final String hint;
  final void Function(String) onChanged;
  final FocusNode? focusNode;
  final Debounce? debounce;

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  late final _ctrl = TextEditingController(text: widget.value);

  @override
  void didUpdateWidget(covariant SearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_ctrl.text != widget.value) _ctrl.text = widget.value;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _ctrl,
      focusNode: widget.focusNode,
      style: Theme.of(context).textTheme.bodyMedium,
      onChanged: (val) {
        if (val.isEmpty) {
          widget.debounce?.cancel();
          widget.onChanged('');
          return;
        }

        if (widget.debounce != null) {
          widget.debounce!.run(() => widget.onChanged(val));
        } else {
          widget.onChanged(val);
        }
      },
      decoration: InputDecoration(
        isDense: false,
        hintText: widget.hint,
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceVariant,
        contentPadding: const EdgeInsets.only(left: 15),
        constraints: const BoxConstraints(minHeight: 35, maxHeight: 40),
        suffixIcon: _ctrl.text.isNotEmpty
            ? IconButton(
                tooltip: 'Clear',
                iconSize: Consts.iconSmall,
                icon: const Icon(Icons.close_rounded),
                color: Theme.of(context).colorScheme.onBackground,
                padding: const EdgeInsets.all(0),
                onPressed: () {
                  _ctrl.clear();
                  widget.debounce?.cancel();
                  widget.onChanged('');
                },
              )
            : null,
      ),
    );
  }
}
