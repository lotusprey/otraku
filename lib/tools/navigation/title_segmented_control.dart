import 'package:flutter/material.dart';
import 'package:otraku/providers/theming.dart';
import 'package:provider/provider.dart';

class TitleSegmentedControl<T> extends StatefulWidget {
  final T value;
  final Map<String, T> pairs;
  final Function(T) onNewValue;
  final Function(T) onSameValue;

  TitleSegmentedControl({
    @required this.value,
    @required this.pairs,
    @required this.onNewValue,
    this.onSameValue,
  });

  @override
  _TitleSegmentedControlState createState() => _TitleSegmentedControlState();
}

class _TitleSegmentedControlState<T> extends State<TitleSegmentedControl> {
  final SizedBox _sizedBox = const SizedBox(width: 10);
  Palette _palette;

  Widget _button(String title, T value) => GestureDetector(
        child: Text(
          title,
          style: value != widget.value
              ? _palette.contrastedTitle
              : _palette.accentedTitle,
        ),
        onTap: () {
          if (value != widget.value) {
            widget.onNewValue(value);
          } else {
            widget.onSameValue(value);
          }
        },
      );

  List<Widget> _buttons() {
    List<Widget> list = [];
    for (var pair in widget.pairs.keys) {
      list.add(_button(pair, widget.pairs[pair]));
      list.add(_sizedBox);
    }
    return list;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _palette = Provider.of<Theming>(context).palette;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: _buttons(),
      ),
    );
  }
}
