import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:otraku/providers/theming.dart';
import 'package:provider/provider.dart';

class SearchPage extends StatefulWidget {
  final Function(String) search;
  final String text;

  SearchPage({
    @required this.text,
    @required this.search,
  });

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController _controller;
  Palette _palette;

  void _search(String searchValue) {
    Navigator.of(context).pop();
    widget.search(searchValue.trim().toLowerCase());
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.text);
    _palette = Provider.of<Theming>(context, listen: false).palette;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _palette.background,
      appBar: CupertinoNavigationBar(
        backgroundColor: _palette.background,
        actionsForegroundColor: _palette.accent,
        middle: Text('Search', style: _palette.contrastedTitle),
        leading: IconButton(
          icon: Icon(
            Icons.close,
            size: Palette.ICON_MEDIUM,
            color: _palette.accent,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        trailing: IconButton(
          icon: Icon(
            Icons.done,
            size: Palette.ICON_MEDIUM,
            color: _palette.accent,
          ),
          onPressed: () => _search(_controller.text),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: TextField(
            textAlign: TextAlign.center,
            style: _palette.contrastedTitle,
            cursorColor: _palette.accent,
            decoration: const InputDecoration(
              border: InputBorder.none,
              counterText: '',
            ),
            scrollPhysics: const BouncingScrollPhysics(),
            maxLines: null,
            maxLength: 70,
            maxLengthEnforced: true,
            autofocus: true,
            textInputAction: TextInputAction.go,
            controller: _controller,
            onSubmitted: (text) => _search(text),
          ),
        ),
      ),
    );
  }
}
