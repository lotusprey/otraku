import 'package:flutter/material.dart';
import 'package:otraku/constants/consts.dart';
import 'package:otraku/widgets/fields/input_field_structure.dart';

class DropDownField<T> extends StatefulWidget {
  final String title;
  final T value;
  final Map<String, T> items;
  final void Function(T) onChanged;
  final String hint;

  DropDownField({
    required this.title,
    required this.value,
    required this.items,
    required this.onChanged,
    this.hint = 'Choose',
  });

  @override
  _DropDownFieldState<T> createState() => _DropDownFieldState<T>();
}

class _DropDownFieldState<T> extends State<DropDownField<T>> {
  late T _value;

  @override
  Widget build(BuildContext context) {
    final items = <DropdownMenuItem<T>>[];
    for (final key in widget.items.keys)
      items.add(DropdownMenuItem(
        value: widget.items[key],
        child: Text(
          key,
          style: widget.items[key] != _value
              ? Theme.of(context).textTheme.bodyText2
              : Theme.of(context).textTheme.bodyText1,
        ),
      ));

    return InputFieldStructure(
      title: widget.title,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: Consts.BORDER_RADIUS,
        ),
        child: DropdownButton<T>(
          value: _value,
          items: items,
          onChanged: (val) {
            final v = val as T;
            setState(() => _value = v);
            widget.onChanged(v);
          },
          hint: Text(
            widget.hint,
            style: Theme.of(context).textTheme.subtitle1,
          ),
          iconEnabledColor: Theme.of(context).colorScheme.primary,
          dropdownColor: Theme.of(context).colorScheme.surface,
          underline: const SizedBox(),
          isExpanded: true,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _value = widget.value;
  }

  @override
  void didUpdateWidget(covariant DropDownField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    _value = widget.value;
  }
}
