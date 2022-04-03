import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/constants/consts.dart';

class SearchField extends StatefulWidget {
  SearchField({
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
  late final TextEditingController _ctrl;
  late bool _empty;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.value);
    _empty = _ctrl.text.isEmpty;
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
      scrollPhysics: Consts.PHYSICS,
      autofocus: widget.onHide != null,
      style: Theme.of(context).textTheme.bodyText2,
      cursorColor: Theme.of(context).colorScheme.primary,
      decoration: InputDecoration(
        isDense: false,
        hintText: widget.hint,
        contentPadding: const EdgeInsets.only(left: 10),
        constraints: const BoxConstraints(minHeight: 35, maxHeight: 35),
        suffixIcon: !_empty
            ? IconButton(
                tooltip: 'Clear',
                iconSize: Consts.ICON_SMALL,
                icon: const Icon(Icons.close_rounded),
                color: Theme.of(context).colorScheme.onBackground,
                splashColor: Colors.transparent,
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
                    iconSize: Consts.ICON_SMALL,
                    icon: const Icon(Ionicons.chevron_forward_outline),
                    color: Theme.of(context).colorScheme.onBackground,
                    splashColor: Colors.transparent,
                    padding: const EdgeInsets.all(0),
                    onPressed: widget.onHide,
                  )
                : null,
      ),
      onChanged: (val) {
        widget.onChange(val);
        if (_empty != _ctrl.text.isEmpty)
          setState(() => _empty = _ctrl.text.isEmpty);
      },
    );
  }
}
