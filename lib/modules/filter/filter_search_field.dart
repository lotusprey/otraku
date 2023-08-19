import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/common/widgets/fields/search_field.dart';
import 'package:otraku/common/widgets/layouts/top_bar.dart';

/// After [_delay] time has passed, since the last [run] call, call [callback].
/// E.g. do a search query after the user stops typing.
class _Debounce {
  static const _delay = Duration(milliseconds: 600);

  Timer? _timer;

  void cancel() => _timer?.cancel();

  void run(void Function() callback) {
    _timer?.cancel();
    _timer = Timer(_delay, callback);
  }
}

class CloseableSearchField extends StatefulWidget {
  const CloseableSearchField({
    required this.title,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  final String title;
  final String? value;
  final void Function(String?) onChanged;
  final bool enabled;

  @override
  State<CloseableSearchField> createState() => _CloseableSearchFieldState();
}

class _CloseableSearchFieldState extends State<CloseableSearchField> {
  final _debounce = _Debounce();

  @override
  void dispose() {
    _debounce.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return Expanded(
        child: Text(
          widget.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleLarge,
        ),
      );
    }

    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (widget.value == null) ...[
            Expanded(
              child: Text(
                widget.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            TopBarIcon(
              tooltip: 'Search',
              icon: Ionicons.search_outline,
              onTap: () => widget.onChanged(''),
            ),
          ] else
            Expanded(
              child: SearchField(
                value: widget.value!,
                hint: widget.title,
                onChange: (val) {
                  if (val.isEmpty) {
                    _debounce.cancel();
                    widget.onChanged('');
                    return;
                  }

                  _debounce.run(() => widget.onChanged(val));
                },
                onHide: () => widget.onChanged(null),
              ),
            ),
        ],
      ),
    );
  }
}
