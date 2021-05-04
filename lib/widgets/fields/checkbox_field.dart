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
  Widget build(BuildContext context) => CheckboxListTile(
        value: _value,
        onChanged: (value) {
          setState(() => _value = value!);
          widget.onChanged(value!);
        },
        title: Text(
          widget.title!,
          style: _value
              ? Theme.of(context).textTheme.bodyText1
              : Theme.of(context).textTheme.bodyText2,
        ),
        activeColor: Theme.of(context).accentColor,
        checkColor: Theme.of(context).backgroundColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 0),
        dense: true,
      );

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }
}
