import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otraku/controllers/config.dart';

class BubbleTabBar<T> extends StatefulWidget {
  final List<String> options;
  final List<T> values;
  final T initial;
  final Function(T) onNewValue;
  final Function(T) onSameValue;
  final bool minimised;
  final bool shrinkWrap;

  const BubbleTabBar({
    @required this.options,
    @required this.values,
    @required this.initial,
    @required this.onNewValue,
    @required this.onSameValue,
    this.minimised = false,
    this.shrinkWrap = false,
  });

  @override
  _BubbleTabBarState createState() => _BubbleTabBarState();
}

class _BubbleTabBarState extends State<BubbleTabBar> {
  int _index;
  TextStyle _selected;
  TextStyle _unselected;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: Config.CONTROL_HEADER_ICON_HEIGHT,
        child: ListView.builder(
          shrinkWrap: widget.shrinkWrap,
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          itemBuilder: (_, index) => GestureDetector(
            onTap: () {
              if (index != _index) {
                setState(() => _index = index);
                widget.onNewValue(widget.values[index]);
              } else {
                widget.onSameValue(widget.values[index]);
              }
            },
            child: AnimatedContainer(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                color: index != _index
                    ? Colors.transparent
                    : Theme.of(context).accentColor,
                borderRadius: Config.BORDER_RADIUS,
              ),
              child: Text(
                widget.options[index],
                style: index != _index ? _unselected : _selected,
              ),
            ),
          ),
          itemCount: widget.options.length,
        ),
      );

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < widget.values.length; i++) {
      if (widget.values[i] == widget.initial) {
        _index = i;
        break;
      }
    }

    _unselected = widget.minimised
        ? Get.theme.textTheme.headline6
        : Get.theme.textTheme.headline3;
    _selected = _unselected.copyWith(color: Get.theme.backgroundColor);
  }
}
