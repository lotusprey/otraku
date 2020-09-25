import 'package:flutter/material.dart';
import 'package:otraku/providers/view_config.dart';

class ExpandableField extends StatefulWidget {
  final String text;
  final Function(String) onChange;

  ExpandableField({
    @required this.text,
    @required this.onChange,
  });

  @override
  _ExpandableFieldState createState() => _ExpandableFieldState();
}

class _ExpandableFieldState extends State<ExpandableField> {
  TextEditingController _controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: ViewConfig.RADIUS,
      ),
      child: TextField(
        scrollPhysics: const BouncingScrollPhysics(),
        controller: _controller,
        onChanged: (text) => widget.onChange(text),
        maxLines: 5,
        cursorColor: Theme.of(context).accentColor,
        style: Theme.of(context).textTheme.bodyText1,
        decoration: InputDecoration(border: InputBorder.none),
      ),
    );
  }

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
