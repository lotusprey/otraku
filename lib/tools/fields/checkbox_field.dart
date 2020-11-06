import 'package:flutter/material.dart';

class CheckboxField extends StatefulWidget {
  final String text;
  final bool initialValue;
  final Function(bool) onChanged;

  CheckboxField({
    @required this.text,
    @required this.onChanged,
    this.initialValue = false,
  });

  @override
  _CheckboxFieldState createState() => _CheckboxFieldState();
}

class _CheckboxFieldState extends State<CheckboxField> {
  bool _value;

  @override
  Widget build(BuildContext context) => GestureDetector(
        child: Row(
          children: [
            Checkbox(
              value: _value,
              onChanged: (_) => _change(),
              activeColor: Theme.of(context).accentColor,
            ),
            Expanded(
              child: Text(
                widget.text,
                style: !_value
                    ? Theme.of(context).textTheme.bodyText1
                    : Theme.of(context).textTheme.bodyText2,
              ),
            ),
          ],
        ),
        onTap: _change,
      );

  void _change() {
    widget.onChanged(!_value);
    setState(() => _value = !_value);
  }

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }
}
