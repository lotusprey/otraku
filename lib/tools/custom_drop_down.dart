import 'package:flutter/material.dart';
import 'package:otraku/providers/theming.dart';
import 'package:provider/provider.dart';

class CustomDropDown extends StatefulWidget {
  final List<String> options;
  final int startIndex;
  final String substituteText;

  CustomDropDown({
    @required this.options,
    this.startIndex,
    this.substituteText = 'Select',
  });

  @override
  _CustomDropDownState createState() => _CustomDropDownState();
}

class _CustomDropDownState extends State<CustomDropDown>
    with SingleTickerProviderStateMixin {
  final GlobalKey _key = GlobalKey();

  int _index;
  Palette _palette;
  AnimationController _controller;
  Animation<double> _opacity;

  bool _showOverlay = false;
  OverlayEntry _entry;
  Offset _overlayOffset;
  double _overlayWidth;

  void _buildOverlay() {
    if (_showOverlay) {
      _entry = OverlayEntry(
        builder: (ctx) => Positioned(
          top: _overlayOffset.dy,
          left: _overlayOffset.dx,
          child: FadeTransition(
            opacity: _opacity,
            child: Material(
              color: _palette.primary,
              borderRadius: BorderRadius.circular(5),
              child: Container(
                width: _overlayWidth,
                padding:
                    const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _buildListOptions(),
                ),
              ),
            ),
          ),
        ),
      );

      WidgetsBinding.instance.addPostFrameCallback((_) {
        Overlay.of(context).insert(_entry);
        _controller.forward();
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _controller.reverse().then((__) {
          if (_entry != null) {
            _entry.remove();
          }
          _entry = null;
        });
      });
    }
  }

  List<Widget> _buildListOptions() {
    List<Widget> list = [];
    for (int i = 0; i < widget.options.length; i++) {
      list.add(GestureDetector(
        child: Container(
          width: _overlayWidth,
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Text(
            widget.options[i],
            style: _index != i ? _palette.paragraph : _palette.exclamation,
          ),
        ),
        onTap: () => setState(() {
          _showOverlay = !_showOverlay;
          _index = i;
        }),
      ));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    _buildOverlay();

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
      onTap: () => setState(() => _showOverlay = !_showOverlay),
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
    _opacity = Tween<double>(begin: 0, end: 1).animate(_controller);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final RenderBox renderBox = _key.currentContext.findRenderObject();
      final offset = renderBox.localToGlobal(Offset.zero);

      _overlayWidth = renderBox.size.width;
      _overlayOffset = Offset(
        offset.dx,
        offset.dy + renderBox.size.height + 10,
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
    if (_showOverlay) {
      _entry.remove();
    }
    _controller.dispose();
    super.dispose();
  }
}
