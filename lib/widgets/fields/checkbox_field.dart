import 'package:flutter/material.dart';

class CheckboxField extends StatefulWidget {
  final String title;
  final bool initial;
  final void Function(bool) onChanged;

  CheckboxField({
    required this.title,
    required this.onChanged,
    this.initial = false,
  });

  @override
  _CheckboxFieldState createState() => _CheckboxFieldState();
}

class _CheckboxFieldState extends State<CheckboxField> {
  late bool _value;

  @override
  Widget build(BuildContext context) => ListTile(
        contentPadding: const EdgeInsets.all(0),
        visualDensity: VisualDensity.compact,
        minVerticalPadding: 0,
        dense: true,
        title: Text(
          widget.title,
          style: Theme.of(context).textTheme.bodyText2,
        ),
        onTap: _onTap,
        trailing: Checkbox(
          value: _value,
          onChanged: (_) => _onTap(),
          activeColor: Theme.of(context).colorScheme.secondary,
          checkColor: Theme.of(context).colorScheme.background,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
        ),
      );

  void _onTap() {
    setState(() => _value = !_value);
    widget.onChanged(_value);
  }

  @override
  void initState() {
    super.initState();
    _value = widget.initial;
  }
}
