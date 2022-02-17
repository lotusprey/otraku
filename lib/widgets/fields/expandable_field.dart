import 'package:flutter/material.dart';
import 'package:otraku/constants/consts.dart';

class ExpandableField extends StatefulWidget {
  final String? text;
  final Function(String) onChanged;

  ExpandableField({
    required this.text,
    required this.onChanged,
  });

  @override
  _ExpandableFieldState createState() => _ExpandableFieldState();
}

class _ExpandableFieldState extends State<ExpandableField> {
  TextEditingController? _controller;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: Consts.BORDER_RAD_MIN,
        ),
        child: TextField(
          style: Theme.of(context).textTheme.bodyText2,
          decoration: const InputDecoration(contentPadding: EdgeInsets.all(10)),
          scrollPhysics: Consts.PHYSICS,
          controller: _controller,
          onChanged: (text) => widget.onChanged(text),
          minLines: 1,
          maxLines: 10,
        ),
      );

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.text);
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }
}
