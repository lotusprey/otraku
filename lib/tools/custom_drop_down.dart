import 'package:flutter/material.dart';
import 'package:otraku/providers/theming.dart';
import 'package:otraku/providers/view_config.dart';
import 'package:provider/provider.dart';

class CustomDropDown extends StatefulWidget {
  final String substituteText;
  final List<String> options;
  final int startIndex;
  final double additionalOffsetY;

  CustomDropDown({
    @required this.options,
    this.substituteText,
    this.startIndex,
    this.additionalOffsetY = 0,
  });

  @override
  _CustomDropDownState createState() => _CustomDropDownState();
}

class _CustomDropDownState extends State<CustomDropDown>
    with SingleTickerProviderStateMixin {
  final GlobalKey _key = GlobalKey();
  int _index;
  Palette _palette;
  bool _active = false;
  AnimationController _controller;
  OverlayState _overlay;
  OverlayEntry _overlayEntry;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: _key,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        decoration: BoxDecoration(
          color: _palette.primary,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _index == null ? widget.substituteText : widget.options[_index],
              style: _palette.paragraph,
            ),
            RotationTransition(
              turns: Tween(begin: 1.0, end: 0.5).animate(_controller),
              child: Icon(
                Icons.keyboard_arrow_down,
                color: _palette.faded,
                size: Palette.ICON_SMALL,
              ),
            ),
          ],
        ),
      ),
      onTap: () {
        if (_active) {
          _overlayEntry.remove();
          _controller.reverse();
        } else {
          _overlay.insert(_overlayEntry);
          _controller.forward();
        }
        _active = !_active;
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _index = widget.startIndex;

    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _overlay = Overlay.of(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final RenderBox renderBox = _key.currentContext.findRenderObject();
      final offset = renderBox.localToGlobal(Offset.zero);
      final offsetY =
          offset.dy + widget.additionalOffsetY + renderBox.size.height + 10;

      _overlayEntry = OverlayEntry(
        builder: (context) => Positioned(
          top: offsetY,
          left: offset.dx,
          child: Material(
            color: _palette.primary,
            borderRadius: BorderRadius.circular(5),
            child: Container(
              width: renderBox.size.width,
              padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widget.options
                    .map((o) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text(o, style: _palette.smallTitle),
                        ))
                    .toList(),
              ),
            ),
          ),
        ),
      );
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _palette = Provider.of<Theming>(context).palette;
  }

  @override
  void dispose() {
    if (_active) {
      _overlayEntry.remove();
    }
    super.dispose();
  }
}
