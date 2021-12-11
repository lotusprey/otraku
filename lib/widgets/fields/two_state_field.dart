import 'package:flutter/material.dart';
import 'package:otraku/constants/consts.dart';

class TwoStateField extends StatefulWidget {
  final String title;
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
      title: Text(widget.title, style: Theme.of(context).textTheme.bodyText2),
      trailing: Container(
        height: 30,
        width: 30,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: !_active
              ? Theme.of(context).colorScheme.surface
              : Theme.of(context).colorScheme.secondary,
        ),
        child: _active
            ? Icon(
                Icons.done_rounded,
                color: Theme.of(context).colorScheme.background,
                size: Consts.ICON_SMALL,
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
