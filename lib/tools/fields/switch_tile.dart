import 'package:flutter/material.dart';

class SwitchTile extends StatefulWidget {
  final String label;
  final bool initialValue;
  final Function(bool) onChanged;

  SwitchTile({
    @required this.label,
    @required this.initialValue,
    @required this.onChanged,
  });

  @override
  _SwitchTileState createState() => _SwitchTileState();
}

class _SwitchTileState extends State<SwitchTile> {
  static const padding = const EdgeInsets.symmetric(horizontal: 10);

  bool value;

  @override
  Widget build(BuildContext context) => SwitchListTile.adaptive(
        contentPadding: padding,
        title: Text(
          widget.label,
          style: Theme.of(context).textTheme.bodyText1,
        ),
        value: value,
        onChanged: (val) {
          widget.onChanged(val);
          setState(() => value = val);
        },
        activeColor: Theme.of(context).accentColor,
      );

  @override
  void initState() {
    super.initState();
    value = widget.initialValue;
  }
}
