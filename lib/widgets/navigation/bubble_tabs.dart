import 'package:flutter/material.dart';
import 'package:otraku/utils/config.dart';

class BubbleTabs<T> extends StatefulWidget {
  final Map<String, T> items;
  final T Function() current;
  final void Function(T) onChanged;
  final void Function() onSame;
  final double itemWidth;

  BubbleTabs({
    required this.items,
    required this.current,
    required this.onChanged,
    required this.onSame,
    required this.itemWidth,
  });

  @override
  _BubbleTabsState<T> createState() => _BubbleTabsState<T>();
}

class _BubbleTabsState<T> extends State<BubbleTabs<T>> {
  late T _val;

  @override
  void initState() {
    super.initState();
    _val = widget.current();
  }

  @override
  Widget build(BuildContext context) {
    final values = widget.items.values;

    return Container(
      height: 30,
      width: widget.itemWidth * values.length + 20,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          for (int i = 0; i < widget.items.length; i++)
            Flexible(
              child: GestureDetector(
                onTap: () {
                  if (_val != values.elementAt(i)) {
                    widget.onChanged(values.elementAt(i));
                    setState(() => _val = values.elementAt(i));
                  } else
                    widget.onSame();
                },
                child: AnimatedContainer(
                  alignment: Alignment.center,
                  duration: const Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    color: _val != values.elementAt(i)
                        ? null
                        : Theme.of(context).colorScheme.secondary,
                    borderRadius: Config.BORDER_RADIUS,
                  ),
                  child: Text(
                    widget.items.keys.elementAt(i),
                    style: _val != values.elementAt(i)
                        ? Theme.of(context).textTheme.headline5
                        : Theme.of(context).textTheme.headline5!.copyWith(
                            color: Theme.of(context).colorScheme.background),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
