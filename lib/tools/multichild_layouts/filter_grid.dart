import 'package:flutter/material.dart';
import 'package:otraku/providers/theming.dart';
import 'package:otraku/providers/view_config.dart';
import 'package:otraku/tools/overlays/dialogs.dart';
import 'package:provider/provider.dart';

class FilterGrid extends StatelessWidget {
  final List<String> options;
  final List<String> descriptions;
  final List<String> optionIn;
  final List<String> optionNotIn;
  final int rows;
  final double whRatio;

  FilterGrid({
    @required this.options,
    @required this.optionIn,
    @required this.optionNotIn,
    @required this.rows,
    this.whRatio = 0.15,
    this.descriptions = const [],
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: rows * 45.0,
      child: GridView.builder(
        padding: ViewConfig.PADDING,
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: rows,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: whRatio,
        ),
        itemBuilder: (_, index) => _FilterOption(
          title: options[index],
          optionIn: optionIn,
          optionNotIn: optionNotIn,
          description: descriptions.length > index ? descriptions[index] : null,
        ),
        itemCount: options.length,
      ),
    );
  }
}

class _FilterOption extends StatefulWidget {
  final String title;
  final List<String> optionIn;
  final List<String> optionNotIn;
  final String description;

  _FilterOption({
    @required this.title,
    @required this.optionIn,
    @required this.optionNotIn,
    this.description,
  });

  @override
  _FilterOptionState createState() => _FilterOptionState();
}

class _FilterOptionState extends State<_FilterOption> {
  static const SizedBox _sizedBox = const SizedBox(width: 5);
  static BorderRadius _borderRadius = BorderRadius.circular(10);

  Palette _palette;
  int _state;

  @override
  void initState() {
    super.initState();
    _palette = Provider.of<Theming>(context, listen: false).palette;
    _state = widget.optionIn.contains(widget.title)
        ? 1
        : widget.optionNotIn.contains(widget.title) ? -1 : 0;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: _state == 0
          ? Container(
              decoration: BoxDecoration(
                color: _palette.primary,
                borderRadius: _borderRadius,
              ),
              child: Center(
                child: Text(widget.title, style: _palette.paragraph),
              ),
            )
          : _state == 1
              ? Container(
                  decoration: BoxDecoration(
                    color: _palette.accent,
                    borderRadius: _borderRadius,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        widget.title,
                        style: _palette.paragraph.copyWith(color: Colors.white),
                      ),
                      _sizedBox,
                      const Icon(Icons.add, size: 15, color: Colors.white),
                    ],
                  ),
                )
              : Container(
                  decoration: BoxDecoration(
                    color: Palette.ERROR,
                    borderRadius: _borderRadius,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        widget.title,
                        style: _palette.paragraph.copyWith(color: Colors.white),
                      ),
                      _sizedBox,
                      const Icon(Icons.remove, size: 15, color: Colors.white),
                    ],
                  ),
                ),
      onTap: () {
        if (_state == 0) {
          widget.optionIn.add(widget.title);
          setState(() => _state = 1);
        } else if (_state == 1) {
          widget.optionIn.remove(widget.title);
          widget.optionNotIn.add(widget.title);
          setState(() => _state = -1);
        } else {
          widget.optionNotIn.remove(widget.title);
          setState(() => _state = 0);
        }
      },
      onLongPress: () {
        if (widget.description != null) {
          showDialog(
            context: context,
            builder: (_) => PopUpAnimation(
              TextDialog(title: widget.title, text: widget.description),
            ),
          );
        }
      },
    );
  }
}
