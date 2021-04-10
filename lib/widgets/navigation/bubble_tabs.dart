import 'package:flutter/material.dart';
import 'package:otraku/utils/config.dart';

class BubbleTabs<T> extends StatefulWidget {
  final List<String> options;
  final List<T> values;
  final T initial;
  final Function(T) onNewValue;
  final Function(T) onSameValue;
  final bool shrinkWrap;
  final bool padding;

  const BubbleTabs({
    required this.options,
    required this.values,
    required this.initial,
    required this.onNewValue,
    required this.onSameValue,
    this.shrinkWrap = true,
    this.padding = true,
  });

  @override
  _BubbleTabsState<T> createState() => _BubbleTabsState<T>();
}

class _BubbleTabsState<T> extends State<BubbleTabs<T>> {
  int? _index;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 35,
        child: ListView.builder(
          shrinkWrap: widget.shrinkWrap,
          scrollDirection: Axis.horizontal,
          physics: Config.PHYSICS,
          padding: widget.padding
              ? const EdgeInsets.symmetric(horizontal: 10)
              : null,
          itemBuilder: (_, index) => GestureDetector(
            onTap: () {
              if (index != _index) {
                setState(() => _index = index);
                widget.onNewValue(widget.values[index]);
              } else
                widget.onSameValue(widget.values[index]);
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
                style: index != _index
                    ? Theme.of(context).textTheme.headline5
                    : Theme.of(context)
                        .textTheme
                        .headline5!
                        .copyWith(color: Theme.of(context).backgroundColor),
              ),
            ),
          ),
          itemCount: widget.options.length,
        ),
      );

  @override
  void initState() {
    super.initState();
    _index = widget.values.indexOf(widget.initial);
    if (_index == -1) _index = 0;
  }
}
