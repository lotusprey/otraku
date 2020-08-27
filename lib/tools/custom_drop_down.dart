import 'package:flutter/material.dart';
import 'package:otraku/providers/theming.dart';
import 'package:provider/provider.dart';

class CustomDropDown extends StatefulWidget {
  final String substituteText;
  final List<String> options;
  final int startIndex;

  CustomDropDown({
    @required this.options,
    this.substituteText,
    this.startIndex,
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
  OverlayEntry _overlayEntry;
  Offset _overlayPos;

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
          Overlay.of(context).insert(_overlayEntry);
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final RenderBox renderBox = _key.currentContext.findRenderObject();
      final size = renderBox.size;
      final offset = renderBox.localToGlobal(Offset.zero);
      _overlayPos = Offset(offset.dx, offset.dy - size.height - 500);
      print(offset);
      print(_overlayPos);
      _overlayEntry = OverlayEntry(
        builder: (context) => Positioned(
          top: _overlayPos.dy,
          left: _overlayPos.dx,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.black, //_palette.primary,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: widget.options
                  .map((o) => Text(o, style: _palette.paragraph))
                  .toList(),
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
}
