import 'package:flutter/material.dart';

class ChipField extends StatefulWidget {
  final String title;
  final bool initiallyPositive;
  final Function(bool) onChanged;
  final Function onRemoved;

  ChipField({
    @required this.title,
    @required this.initiallyPositive,
    @required this.onChanged,
    @required this.onRemoved,
    key,
  }) : super(key: key);

  @override
  _ChipFieldState createState() => _ChipFieldState();
}

class _ChipFieldState extends State<ChipField> {
  bool _isPositive;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () {
          setState(() => _isPositive = !_isPositive);
          widget.onChanged(_isPositive);
        },
        child: Chip(
          backgroundColor: _isPositive
              ? Theme.of(context).accentColor
              : Theme.of(context).errorColor,
          label:
              Text(widget.title, style: Theme.of(context).textTheme.bodyText1),
          onDeleted: widget.onRemoved,
        ),
      );

  @override
  void initState() {
    super.initState();
    _isPositive = widget.initiallyPositive;
  }
}
