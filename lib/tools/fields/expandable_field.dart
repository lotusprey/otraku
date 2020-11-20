import 'package:flutter/material.dart';
import 'package:otraku/controllers/config.dart';

class ExpandableField extends StatefulWidget {
  final String text;
  final Function(String) onChanged;

  ExpandableField({
    @required this.text,
    @required this.onChanged,
  });

  @override
  _ExpandableFieldState createState() => _ExpandableFieldState();
}

class _ExpandableFieldState extends State<ExpandableField> {
  TextEditingController _controller;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: Config.BORDER_RADIUS,
        ),
        child: TextField(
          scrollPhysics: const BouncingScrollPhysics(),
          controller: _controller,
          onChanged: (text) => widget.onChanged(text),
          minLines: 1,
          maxLines: 5,
          cursorColor: Theme.of(context).accentColor,
          style: Theme.of(context).textTheme.bodyText1,
          decoration: InputDecoration(border: InputBorder.none),
        ),
      );

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.text);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
