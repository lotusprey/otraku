import 'package:flutter/material.dart';

class TitleSegmentedControl<T> extends StatefulWidget {
  final T initialValue;
  final Map<String, T> pairs;
  final Function(T) onNewValue;
  final Function(T) onSameValue;
  final bool small;

  TitleSegmentedControl({
    @required this.initialValue,
    @required this.pairs,
    @required this.onNewValue,
    @required this.onSameValue,
    this.small = false,
  });

  @override
  _TitleSegmentedControlState createState() => _TitleSegmentedControlState();
}

class _TitleSegmentedControlState<T> extends State<TitleSegmentedControl> {
  final SizedBox _space = const SizedBox(width: 10);

  T _value;
  bool _didChangeDependencies = false;
  TextStyle _selected;
  TextStyle _unSelected;

  Widget _button(String title, T value) => GestureDetector(
        child: Text(
          title,
          style: value != _value ? _unSelected : _selected,
        ),
        onTap: () {
          if (value != _value) {
            setState(() => _value = value);
            widget.onNewValue(value);
          } else {
            widget.onSameValue(value);
          }
        },
      );

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _space,
          for (final pair in widget.pairs.keys) ...[
            _button(pair, widget.pairs[pair]),
            _space,
          ],
        ],
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didChangeDependencies) {
      _value = widget.initialValue;
      _selected = widget.small
          ? Theme.of(context).textTheme.headline5
          : Theme.of(context).textTheme.headline2;
      _unSelected = widget.small
          ? Theme.of(context).textTheme.headline6
          : Theme.of(context).textTheme.headline3;
      _didChangeDependencies = true;
    }
  }
}
