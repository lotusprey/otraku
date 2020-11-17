import 'package:flutter/material.dart';

class ThreeStateField extends StatefulWidget {
  final String title;
  final int initialState;
  final Function(int) onChanged;

  ThreeStateField({
    @required this.title,
    @required this.initialState,
    @required this.onChanged,
  });

  @override
  _ThreeStateFieldState createState() => _ThreeStateFieldState();
}

class _ThreeStateFieldState extends State<ThreeStateField> {
  int _state;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      title: Text(widget.title, style: Theme.of(context).textTheme.bodyText1),
      trailing: Container(
        height: 35,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _state == 0
              ? Theme.of(context).primaryColor
              : _state == 1
                  ? Theme.of(context).accentColor
                  : Theme.of(context).errorColor,
        ),
        child: Icon(
          _state < 2 ? Icons.add : Icons.remove,
          color: _state == 0
              ? Theme.of(context).primaryColor
              : Theme.of(context).dividerColor,
        ),
      ),
      onTap: () {
        if (_state < 2) {
          setState(() => _state++);
        } else {
          setState(() => _state = 0);
        }
        widget.onChanged(_state);
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _state = widget.initialState;
    if (_state < 0 || _state > 2) _state = 0;
  }
}
