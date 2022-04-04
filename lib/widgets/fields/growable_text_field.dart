import 'package:flutter/material.dart';
import 'package:otraku/constants/consts.dart';

// A text field that grows to up to 10 lines, if necessary.
class GrowableTextField extends StatefulWidget {
  GrowableTextField({
    required this.text,
    required this.onChanged,
  });

  final String text;
  final void Function(String) onChanged;

  @override
  _GrowableTextFieldState createState() => _GrowableTextFieldState();
}

class _GrowableTextFieldState extends State<GrowableTextField> {
  late final TextEditingController _ctrl;

  @override
  Widget build(BuildContext context) => TextField(
        minLines: 1,
        maxLines: 10,
        style: Theme.of(context).textTheme.bodyText2,
        decoration: const InputDecoration(contentPadding: Consts.PADDING),
        controller: _ctrl,
        onChanged: (text) => widget.onChanged(text),
      );

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.text);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }
}
