import 'package:flutter/material.dart';

class CheckboxField extends StatefulWidget {
  final String? title;
  final bool initialValue;
  final Function(bool) onChanged;

  CheckboxField({
    required this.title,
    required this.onChanged,
    this.initialValue = false,
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
          widget.title!,
          style: _value
              ? Theme.of(context).textTheme.bodyText1
              : Theme.of(context).textTheme.bodyText2,
        ),
        onTap: onTap,
        trailing: Checkbox(
          value: _value,
          onChanged: (_) => onTap(),
          activeColor: Theme.of(context).accentColor,
          checkColor: Theme.of(context).backgroundColor,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
        ),
      );

  void onTap() {
    setState(() => _value = !_value);
    widget.onChanged(_value);
  }

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }
}
