import 'package:flutter/material.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/util/debounce.dart';

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
    return Semantics(
      label: 'Search',
      child: TextField(
        controller: _ctrl,
        focusNode: widget.focusNode,
        style: TextTheme.of(context).bodyMedium,
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
          fillColor: ColorScheme.of(context).surfaceContainerHighest,
          contentPadding: const EdgeInsets.only(left: 15),
          constraints: const BoxConstraints(minHeight: 35, maxHeight: 40),
          suffixIcon: _ctrl.text.isNotEmpty
              ? IconButton(
                  tooltip: 'Clear',
                  iconSize: Theming.iconSmall,
                  icon: const Icon(Icons.close_rounded),
                  color: ColorScheme.of(context).onSurface,
                  padding: const EdgeInsets.all(0),
                  onPressed: () {
                    _ctrl.clear();
                    widget.debounce?.cancel();
                    widget.onChanged('');
                  },
                )
              : null,
        ),
      ),
    );
  }
}
