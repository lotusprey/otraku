import 'package:flutter/material.dart';
import 'package:otraku/utils/config.dart';

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
          color: Theme.of(context).primaryColor,
          borderRadius: Config.BORDER_RADIUS,
        ),
        child: TextField(
          decoration: const InputDecoration(contentPadding: EdgeInsets.all(10)),
          scrollPhysics: Config.PHYSICS,
          controller: _controller,
          onChanged: (text) => widget.onChanged(text),
          minLines: 1,
          maxLines: 5,
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
