import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:otraku/enums/browsable_enum.dart';
import 'package:otraku/enums/theme_enum.dart';
import 'package:otraku/controllers/explorable.dart';
import 'package:otraku/controllers/config.dart';

class ExploreSearchBar extends StatelessWidget {
  final String initialValue;
  final Function(String) onChanged;

  ExploreSearchBar(this.initialValue, this.onChanged);

  @override
  Widget build(BuildContext context) {
    final totalWidth = MediaQuery.of(context).size.width - 20;

    return Obx(() {
      final type = Get.find<Explorable>().type;

      return AnimatedContainer(
        width: totalWidth -
            (type == Browsable.anime || type == Browsable.manga
                ? Config.MATERIAL_TAP_TARGET_SIZE * 2
                : 0),
        height: Config.MATERIAL_TAP_TARGET_SIZE,
        duration: const Duration(milliseconds: 100),
        child: Center(
          child: _HeaderSearchBar(
            initialValue,
            onChanged,
          ),
        ),
      );
    });
  }
}

class CollectionSearchBar extends StatelessWidget {
  final String initialValue;
  final Function(String) onChanged;

  CollectionSearchBar(this.initialValue, this.onChanged);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: Config.MATERIAL_TAP_TARGET_SIZE,
      width: MediaQuery.of(context).size.width -
          Config.MATERIAL_TAP_TARGET_SIZE -
          20,
      child: Center(child: _HeaderSearchBar(initialValue, onChanged)),
    );
  }
}

class _HeaderSearchBar extends StatefulWidget {
  final String initialValue;
  final Function(String) onChanged;

  _HeaderSearchBar(this.initialValue, this.onChanged);

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
      height: Config.CONTROL_HEADER_ICON_HEIGHT,
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
            borderRadius: Config.BORDER_RADIUS,
            borderSide: BorderSide.none,
          ),
          prefixIcon: Icon(
            FluentSystemIcons.ic_fluent_search_regular,
            size: Styles.ICON_SMALL,
            color: Theme.of(context).disabledColor,
          ),
          suffixIcon: _isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.close),
                  iconSize: Styles.ICON_SMALLER,
                  color: Theme.of(context).disabledColor,
                  onPressed: () {
                    widget.onChanged(null);
                    _controller.clear();
                    setState(() => _isEmpty = true);
                    _focus.unfocus();
                  },
                ),
        ),
        onChanged: (text) {
          widget.onChanged(text);
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
