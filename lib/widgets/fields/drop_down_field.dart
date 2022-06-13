import 'package:flutter/material.dart';
import 'package:otraku/constants/consts.dart';
import 'package:otraku/widgets/fields/labeled_field.dart';

class DropDownField<T> extends StatefulWidget {
  DropDownField({
    required this.title,
    required this.value,
    required this.items,
    required this.onChanged,
    this.hint = 'Choose',
  });

  final String title;
  final T value;
  final Map<String, T> items;
  final void Function(T) onChanged;
  final String hint;

  @override
  _DropDownFieldState<T> createState() => _DropDownFieldState<T>();
}

class _DropDownFieldState<T> extends State<DropDownField<T>> {
  late T _value;

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

    return LabeledField(
      label: widget.title,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: Consts.borderRadiusMin,
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
          iconEnabledColor: Theme.of(context).colorScheme.surfaceVariant,
          dropdownColor: Theme.of(context).colorScheme.surface,
          underline: const SizedBox(),
          isExpanded: true,
        ),
      ),
    );
  }
}
