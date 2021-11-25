import 'package:flutter/material.dart';
import 'package:otraku/constants/config.dart';

class BubbleTabs<T> extends StatefulWidget {
  final Map<String, T> items;
  final T Function() current;
  final void Function(T) onChanged;
  final void Function() onSame;

  BubbleTabs({
    required this.items,
    required this.current,
    required this.onChanged,
    required this.onSame,
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
  void didUpdateWidget(covariant BubbleTabs<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    _val = widget.current();
  }

  @override
  Widget build(BuildContext context) {
    final values = widget.items.values;

    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < widget.items.length; i++)
            GestureDetector(
              onTap: () {
                if (_val != values.elementAt(i)) {
                  widget.onChanged(values.elementAt(i));
                  setState(() => _val = values.elementAt(i));
                } else
                  widget.onSame();
              },
              child: AnimatedContainer(
                padding: const EdgeInsets.symmetric(horizontal: 10),
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
                      ? Theme.of(context).textTheme.headline2
                      : Theme.of(context).textTheme.headline2!.copyWith(
                          color: Theme.of(context).colorScheme.background),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
