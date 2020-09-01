import 'package:flutter/material.dart';
import 'package:otraku/models/tuple.dart';
import 'package:otraku/providers/theming.dart';
import 'package:otraku/tools/overlays/dialogs.dart';
import 'package:provider/provider.dart';

class TextGrid extends StatelessWidget {
  final List<Tuple<String, String>> options;
  final List<String> optionIn;
  final List<String> optionNotIn;

  TextGrid({
    @required this.options,
    @required this.optionIn,
    @required this.optionNotIn,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: options
          .map((option) => _TextGridButton(
                title: option.item1,
                optionIn: optionIn,
                optionNotIn: optionNotIn,
                dialogText: option.item2,
              ))
          .toList(),
    );
  }
}

class _TextGridButton extends StatefulWidget {
  static const SizedBox _sizedBox = const SizedBox(width: 5);
  static const EdgeInsets _edgeInsets = const EdgeInsets.all(5);
  static BorderRadius _borderRadius = BorderRadius.circular(5);

  final String title;
  final List<String> optionIn;
  final List<String> optionNotIn;
  final String dialogText;

  _TextGridButton({
    @required this.title,
    @required this.optionIn,
    @required this.optionNotIn,
    this.dialogText,
  });

  @override
  __TextGridButtonState createState() => __TextGridButtonState();
}

class __TextGridButtonState extends State<_TextGridButton> {
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
                borderRadius: _TextGridButton._borderRadius,
              ),
              padding: _TextGridButton._edgeInsets,
              child: Text(widget.title, style: _palette.detail),
            )
          : _state == 1
              ? Container(
                  padding: _TextGridButton._edgeInsets,
                  decoration: BoxDecoration(
                    color: _palette.accent,
                    borderRadius: _TextGridButton._borderRadius,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        widget.title,
                        style: _palette.detail.copyWith(color: Colors.white),
                      ),
                      _TextGridButton._sizedBox,
                      const Icon(Icons.add, size: 15, color: Colors.white),
                    ],
                  ),
                )
              : Container(
                  padding: _TextGridButton._edgeInsets,
                  decoration: BoxDecoration(
                    color: Color(0xffd63324),
                    borderRadius: _TextGridButton._borderRadius,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        widget.title,
                        style: _palette.detail.copyWith(color: Colors.white),
                      ),
                      _TextGridButton._sizedBox,
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
        if (widget.dialogText != null) {
          showDialog(
            context: context,
            builder: (ctx) => PopUpAnimation(
              TextDialog(title: widget.title, text: widget.dialogText),
            ),
          );
        }
      },
    );
  }
}
