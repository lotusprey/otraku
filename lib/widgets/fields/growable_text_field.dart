import 'package:flutter/material.dart';
import 'package:otraku/utils/consts.dart';

// A text field that grows to up to 10 lines, if necessary.
class GrowableTextField extends StatefulWidget {
  const GrowableTextField({
    required this.text,
    required this.onChanged,
  });

  final String text;
  final void Function(String) onChanged;

  @override
  GrowableTextFieldState createState() => GrowableTextFieldState();
}

class GrowableTextFieldState extends State<GrowableTextField> {
  late final _ctrl = TextEditingController(text: widget.text);

  @override
  Widget build(BuildContext context) => Card(
        child: TextField(
          minLines: 1,
          maxLines: 10,
          style: Theme.of(context).textTheme.bodyText2,
          decoration: const InputDecoration(contentPadding: Consts.padding),
          controller: _ctrl,
          onChanged: (text) => widget.onChanged(text),
        ),
      );

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }
}
