import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:otraku/providers/design.dart';
import 'package:otraku/providers/media_group_provider.dart';
import 'package:otraku/providers/view_config.dart';

class HeaderSearchBar extends StatefulWidget {
  final MediaGroupProvider provider;

  HeaderSearchBar(this.provider);

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
          controller: _controller,
          cursorColor: Theme.of(context).accentColor,
          style: Theme.of(context).textTheme.bodyText1,
          inputFormatters: [
            LengthLimitingTextInputFormatter(30),
          ],
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.all(5),
            filled: true,
            fillColor: Theme.of(context).primaryColor,
            border: OutlineInputBorder(
              borderRadius: ViewConfig.BORDER_RADIUS,
              borderSide: BorderSide.none,
            ),
            prefixIcon: Icon(
              FluentSystemIcons.ic_fluent_search_regular,
              size: Design.ICON_SMALL,
            ),
            suffixIcon: _isEmpty
                ? null
                : IconButton(
                    icon: const Icon(Icons.close),
                    iconSize: Design.ICON_SMALLER,
                    onPressed: () {
                      widget.provider.search = null;
                      _controller.clear();
                      setState(() => _isEmpty = true);
                      _focus.unfocus();
                    },
                  ),
          ),
          onChanged: (text) {
            widget.provider.search = text;
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
