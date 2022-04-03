import 'package:flutter/material.dart';
import 'package:otraku/constants/consts.dart';

class TabSegments<T> extends StatefulWidget {
  TabSegments({
    required this.items,
    required this.current,
    required this.onChanged,
  });

  final Map<String, T> items;
  final T Function() current;
  final void Function(T) onChanged;

  @override
  State<TabSegments<T>> createState() => _TabSegmentsState<T>();
}

class _TabSegmentsState<T> extends State<TabSegments<T>> {
  late T _value;

  @override
  void initState() {
    super.initState();
    _value = widget.current();
  }

  @override
  void didUpdateWidget(covariant TabSegments<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    _value = widget.current();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          for (int i = 0; i < widget.items.length; i++)
            Flexible(
              child: GestureDetector(
                onTap: () {
                  if (_value == widget.items.values.elementAt(i)) return;
                  widget.onChanged(widget.items.values.elementAt(i));
                  setState(() => _value = widget.items.values.elementAt(i));
                },
                child: AnimatedContainer(
                  alignment: Alignment.center,
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: _value != widget.items.values.elementAt(i)
                        ? null
                        : Theme.of(context).colorScheme.primary,
                    borderRadius: Consts.BORDER_RAD_MIN,
                  ),
                  child: Text(
                    widget.items.keys.elementAt(i),
                    style: _value != widget.items.values.elementAt(i)
                        ? Theme.of(context).textTheme.headline2
                        : Theme.of(context).textTheme.headline2!.copyWith(
                              color: Theme.of(context).colorScheme.background,
                            ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
