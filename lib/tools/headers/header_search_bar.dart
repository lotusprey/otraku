import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:otraku/enums/browsable_enum.dart';
import 'package:otraku/providers/design.dart';
import 'package:otraku/providers/explorable.dart';
import 'package:otraku/providers/view_config.dart';
import 'package:provider/provider.dart';

class ExploreSearchBar extends StatelessWidget {
  final String initialValue;
  final Function(String) updateValue;

  ExploreSearchBar(this.initialValue, this.updateValue);

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width - 20;

    final type = Provider.of<Explorable>(context).type;
    if (type == Browsable.anime || type == Browsable.manga)
      width -= ViewConfig.MATERIAL_TAP_TARGET_SIZE * 2;

    return AnimatedContainer(
      width: width,
      height: ViewConfig.MATERIAL_TAP_TARGET_SIZE,
      duration: const Duration(milliseconds: 100),
      child: Center(
        child: _HeaderSearchBar(
          initialValue,
          updateValue,
        ),
      ),
    );
  }
}

class CollectionSearchBar extends StatelessWidget {
  final String initialValue;
  final Function(String) updateValue;

  CollectionSearchBar(this.initialValue, this.updateValue);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: ViewConfig.MATERIAL_TAP_TARGET_SIZE,
      width: MediaQuery.of(context).size.width -
          ViewConfig.MATERIAL_TAP_TARGET_SIZE -
          20,
      child: Center(child: _HeaderSearchBar(initialValue, updateValue)),
    );
  }
}

class _HeaderSearchBar extends StatefulWidget {
  final String initialValue;
  final Function(String) updateValue;

  _HeaderSearchBar(this.initialValue, this.updateValue);

  @override
  __HeaderSearchBarState createState() => __HeaderSearchBarState();
}

class __HeaderSearchBarState extends State<_HeaderSearchBar> {
  TextEditingController _controller;
  bool _isEmpty;
  FocusNode _focus;

  @override
  Widget build(BuildContext context) {
    return Container(
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
            color: Theme.of(context).disabledColor,
          ),
          suffixIcon: _isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.close),
                  iconSize: Design.ICON_SMALLER,
                  color: Theme.of(context).disabledColor,
                  onPressed: () {
                    widget.updateValue(null);
                    _controller.clear();
                    setState(() => _isEmpty = true);
                    _focus.unfocus();
                  },
                ),
        ),
        onChanged: (text) {
          widget.updateValue(text);
          if (text.length > 0) {
            setState(() => _isEmpty = false);
          } else {
            setState(() => _isEmpty = true);
          }
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue ?? '');
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
