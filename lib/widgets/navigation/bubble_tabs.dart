import 'package:flutter/material.dart';
import 'package:otraku/utils/config.dart';

class BubbleTabs<T> extends StatefulWidget {
  final List<String> options;
  final List<T> values;
  final T initial;
  final Function(T) onNewValue;
  final Function(T) onSameValue;

  const BubbleTabs({
    required this.options,
    required this.values,
    required this.initial,
    required this.onNewValue,
    required this.onSameValue,
  });

  @override
  _BubbleTabsState<T> createState() => _BubbleTabsState<T>();
}

class _BubbleTabsState<T> extends State<BubbleTabs<T>> {
  int? _index;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 35,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int i = 0; i < widget.options.length; i++) ...[
              GestureDetector(
                onTap: () {
                  if (_index != i) {
                    setState(() => _index = i);
                    widget.onNewValue(widget.values[i]);
                  } else
                    widget.onSameValue(widget.values[i]);
                },
                child: AnimatedContainer(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  duration: const Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    color: _index != i
                        ? Colors.transparent
                        : Theme.of(context).accentColor,
                    borderRadius: Config.BORDER_RADIUS,
                  ),
                  child: Text(
                    widget.options[i],
                    style: _index != i
                        ? Theme.of(context).textTheme.headline5
                        : Theme.of(context)
                            .textTheme
                            .headline5!
                            .copyWith(color: Theme.of(context).backgroundColor),
                  ),
                ),
              ),
            ]
          ],
        ),
      );

  @override
  void initState() {
    super.initState();
    _index = widget.values.indexOf(widget.initial);
    if (_index == -1) _index = 0;
  }
}
