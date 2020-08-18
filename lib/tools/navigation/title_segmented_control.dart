import 'package:flutter/material.dart';
import 'package:otraku/providers/theming.dart';
import 'package:provider/provider.dart';

class TitleSegmentedControl<T> extends StatefulWidget {
  final Function(T) function;
  final Map<String, T> pairs;
  final int startIndex;

  TitleSegmentedControl({
    @required this.function,
    @required this.pairs,
    this.startIndex = 0,
  });

  @override
  _TitleSegmentedControlState createState() => _TitleSegmentedControlState();
}

class _TitleSegmentedControlState<T> extends State<TitleSegmentedControl> {
  final SizedBox _sizedBox = const SizedBox(width: 10);
  Palette _palette;
  int _current;

  Widget _button(String title, T value, int index) => GestureDetector(
        child: Text(
          title,
          style: index != _current
              ? _palette.titleContrasted
              : _palette.titleAccented,
        ),
        onTap: () {
          setState(() => _current = index);
          widget.function(value);
        },
      );

  List<Widget> _buttons() {
    List<Widget> list = [];
    int index = 0;

    for (var pair in widget.pairs.keys) {
      list.add(_button(pair, widget.pairs[pair], index));
      list.add(_sizedBox);
      index++;
    }
    return list;
  }

  @override
  void initState() {
    super.initState();
    _current = widget.startIndex;
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
