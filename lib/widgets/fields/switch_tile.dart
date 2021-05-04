import 'package:flutter/material.dart';

class SwitchTile extends StatefulWidget {
  final String title;
  final bool initialValue;
  final Function(bool) onChanged;

  SwitchTile({
    required this.title,
    required this.onChanged,
    required this.initialValue,
  });

  @override
  _SwitchTileState createState() => _SwitchTileState();
}

class _SwitchTileState extends State<SwitchTile> {
  late bool _value;

  @override
  Widget build(BuildContext context) => SwitchListTile.adaptive(
        contentPadding: const EdgeInsets.all(0),
        title: Text(widget.title),
        value: _value,
        onChanged: (val) {
          setState(() => _value = val);
          widget.onChanged(val);
        },
      );

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }
}
