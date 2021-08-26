import 'package:flutter/material.dart';

class ChipField extends StatefulWidget {
  final String title;
  final bool initiallyPositive;
  final Function(bool)? onChanged;
  final Function onRemoved;

  ChipField({
    required this.title,
    required this.initiallyPositive,
    required this.onRemoved,
    this.onChanged,
    key,
  }) : super(key: key);

  @override
  _ChipFieldState createState() => _ChipFieldState();
}

class _ChipFieldState extends State<ChipField> {
  late bool _isPositive;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () {
          if (widget.onChanged == null) return;
          setState(() => _isPositive = !_isPositive);
          widget.onChanged!(_isPositive);
        },
        child: Chip(
          backgroundColor: _isPositive
              ? Theme.of(context).colorScheme.secondary
              : Theme.of(context).colorScheme.error,
          label: Text(widget.title, style: Theme.of(context).textTheme.button),
          deleteIconColor: Theme.of(context).colorScheme.background,
          onDeleted: widget.onRemoved as void Function()?,
        ),
      );

  @override
  void initState() {
    super.initState();
    _isPositive = widget.initiallyPositive;
  }
}
