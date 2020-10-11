import 'package:flutter/material.dart';

class TitleSegmentedControl<T> extends StatefulWidget {
  final T value;
  final Map<String, T> pairs;
  final Function(T) onNewValue;
  final Function(T) onSameValue;
  final bool small;

  TitleSegmentedControl({
    @required this.value,
    @required this.pairs,
    @required this.onNewValue,
    @required this.onSameValue,
    this.small = false,
  });

  @override
  _TitleSegmentedControlState createState() => _TitleSegmentedControlState();
}

class _TitleSegmentedControlState<T> extends State<TitleSegmentedControl> {
  final SizedBox _sizedBox = const SizedBox(width: 10);

  bool _didChangeDependencies = false;
  TextStyle _selected;
  TextStyle _unSelected;

  Widget _button(String title, T value) => GestureDetector(
        child: Text(
          title,
          style: value != widget.value ? _unSelected : _selected,
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didChangeDependencies) {
      _selected = widget.small
          ? Theme.of(context).textTheme.bodyText2
          : Theme.of(context).textTheme.headline2;
      _unSelected = widget.small
          ? Theme.of(context).textTheme.bodyText1
          : Theme.of(context).textTheme.headline3;
      _didChangeDependencies = true;
    }
  }
}
