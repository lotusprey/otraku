import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:otraku/providers/media_group_provider.dart';
import 'package:otraku/providers/theming.dart';
import 'package:otraku/providers/view_config.dart';

class HeaderSearchBar extends StatefulWidget {
  final MediaGroupProvider provider;
  final Palette palette;

  HeaderSearchBar(this.provider, this.palette);

  @override
  _HeaderSearchBarState createState() => _HeaderSearchBarState();
}

class _HeaderSearchBarState extends State<HeaderSearchBar> {
  TextEditingController _controller;
  bool _isEmpty;
  FocusNode _focus;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: ViewConfig.CONTROL_HEADER_ICON_HEIGHT,
        padding: const EdgeInsets.only(right: 10),
        child: TextField(
          focusNode: _focus,
          //showCursor to false is a workaround for a bug
          //that scrolls the page to the top, whenever the
          //field is focused
          showCursor: false,
          controller: _controller,
          cursorColor: widget.palette.accent,
          style: widget.palette.paragraph,
          inputFormatters: [
            LengthLimitingTextInputFormatter(30),
          ],
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.all(5),
            filled: true,
            fillColor: widget.palette.primary,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: BorderSide.none,
            ),
            prefixIcon: Icon(
              LineAwesomeIcons.search,
              color: widget.palette.faded,
              size: Palette.ICON_SMALL,
            ),
            suffixIcon: _isEmpty
                ? null
                : IconButton(
                    icon: const Icon(CupertinoIcons.clear),
                    color: widget.palette.faded,
                    iconSize: Palette.ICON_SMALLER,
                    onPressed: () {
                      widget.provider.search = null;
                      _controller.clear();
                      _focus.unfocus();
                      setState(() => _isEmpty = true);
                    },
                  ),
          ),
          onChanged: (text) {
            widget.provider.search = text.trim();
            if (text.length > 0) {
              setState(() => _isEmpty = false);
            } else {
              setState(() => _isEmpty = true);
            }
          },
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.provider.search ?? '');
    _isEmpty = _controller.text.length == 0;
    _focus = FocusNode();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }
}
