import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/common/utils/consts.dart';

class SearchField extends StatefulWidget {
  const SearchField({
    required this.hint,
    required this.onChange,
    required this.value,
    this.onHide,
  });

  final String value;
  final String hint;
  final void Function(String) onChange;
  final void Function()? onHide;

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  late final TextEditingController _ctrl = TextEditingController(
    text: widget.value,
  );
  late bool _empty = _ctrl.text.isEmpty;
  FocusNode? _focus;

  @override
  void initState() {
    super.initState();
    if (widget.onHide != null && _empty) {
      _focus = FocusNode();
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _focus!.requestFocus(),
      );
    }
  }

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
      focusNode: _focus,
      style: Theme.of(context).textTheme.bodyMedium,
      decoration: InputDecoration(
        isDense: false,
        hintText: widget.hint,
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceVariant,
        contentPadding: const EdgeInsets.only(left: 15),
        constraints: const BoxConstraints(minHeight: 35, maxHeight: 35),
        suffixIcon: !_empty
            ? IconButton(
                tooltip: 'Clear',
                iconSize: Consts.iconSmall,
                icon: const Icon(Icons.close_rounded),
                color: Theme.of(context).colorScheme.onBackground,
                padding: const EdgeInsets.all(0),
                onPressed: () {
                  _ctrl.clear();
                  widget.onChange('');
                  setState(() => _empty = true);
                },
              )
            : widget.onHide != null
                ? IconButton(
                    tooltip: 'Hide',
                    iconSize: Consts.iconSmall,
                    icon: const Icon(Ionicons.chevron_forward_outline),
                    color: Theme.of(context).colorScheme.onBackground,
                    padding: const EdgeInsets.all(0),
                    onPressed: widget.onHide,
                  )
                : null,
      ),
      onChanged: (val) {
        widget.onChange(val);
        if (_empty != _ctrl.text.isEmpty) {
          setState(() => _empty = _ctrl.text.isEmpty);
        }
      },
    );
  }
}
