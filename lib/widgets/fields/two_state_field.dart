import 'package:flutter/material.dart';
import 'package:otraku/enums/themes.dart';

class TwoStateField extends StatefulWidget {
  final String? title;
  final bool initial;
  final Function(bool) onChanged;

  TwoStateField({
    required this.title,
    required this.initial,
    required this.onChanged,
  });

  @override
  _TwoStateFieldState createState() => _TwoStateFieldState();
}

class _TwoStateFieldState extends State<TwoStateField> {
  late bool _active;

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
          color: !_active
              ? Theme.of(context).primaryColor
              : Theme.of(context).accentColor,
        ),
        child: _active
            ? Icon(
                Icons.done_rounded,
                color: Theme.of(context).backgroundColor,
                size: Style.ICON_SMALL,
              )
            : null,
      ),
      onTap: () {
        setState(() => _active = !_active);
        widget.onChanged(_active);
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _active = widget.initial;
  }
}
