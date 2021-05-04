import 'package:flutter/material.dart';

class ThreeStateField extends StatefulWidget {
  final String? title;
  final int initialState;
  final Function(int) onChanged;

  ThreeStateField({
    required this.title,
    required this.initialState,
    required this.onChanged,
  });

  @override
  _ThreeStateFieldState createState() => _ThreeStateFieldState();
}

class _ThreeStateFieldState extends State<ThreeStateField> {
  late int _state;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10),
      title: Text(widget.title!),
      trailing: Container(
        height: 30,
        width: 30,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _state == 0
              ? Theme.of(context).primaryColor
              : _state == 1
                  ? Theme.of(context).accentColor
                  : Theme.of(context).errorColor,
        ),
        child: _state != 0
            ? Icon(
                _state == 1 ? Icons.add_rounded : Icons.remove_rounded,
                color: Theme.of(context).backgroundColor,
              )
            : null,
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
