import 'package:flutter/material.dart';

class SwitchTile extends StatefulWidget {
  final String title;
  final bool? initialValue;
  final Function(bool) onChanged;

  SwitchTile({
    required this.title,
    required this.initialValue,
    required this.onChanged,
  });

  @override
  _SwitchTileState createState() => _SwitchTileState();
}

class _SwitchTileState extends State<SwitchTile> {
  bool? _value;

  @override
  Widget build(BuildContext context) => SwitchListTile.adaptive(
        contentPadding: const EdgeInsets.symmetric(horizontal: 10),
        title: Text(
          widget.title,
          style: Theme.of(context).textTheme.bodyText1,
        ),
        value: _value!,
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
