import 'package:flutter/material.dart';
import 'package:otraku/common/utils/consts.dart';

class SegmentSwitcher extends StatefulWidget {
  const SegmentSwitcher({
    required this.items,
    required this.current,
    required this.onChanged,
  });

  final int current;
  final List<String> items;
  final void Function(int) onChanged;

  @override
  State<SegmentSwitcher> createState() => _SegmentSwitcherState();
}

class _SegmentSwitcherState extends State<SegmentSwitcher> {
  late int _index = widget.current;

  @override
  void didUpdateWidget(covariant SegmentSwitcher oldWidget) {
    super.didUpdateWidget(oldWidget);
    _index = widget.current;
  }

  @override
  Widget build(BuildContext context) {
    final itemRow = Row(
      children: [
        for (int i = 0; i < widget.items.length; i++)
          Flexible(
            child: InkWell(
              borderRadius: Consts.borderRadiusMax,
              onTap: () {
                if (_index == i) return;
                setState(() => _index = i);
                widget.onChanged(_index);
              },
              child: Center(
                child: Text(
                  widget.items[i],
                  overflow: TextOverflow.ellipsis,
                  style: _index != i
                      ? Theme.of(context).textTheme.titleMedium
                      : Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                ),
              ),
            ),
          ),
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = constraints.maxWidth / widget.items.length;

        return Center(
          child: SizedBox(
            height: 35,
            width: constraints.maxWidth,
            child: Card(
              shape: const RoundedRectangleBorder(
                borderRadius: Consts.borderRadiusMax,
              ),
              child: Stack(
                children: [
                  AnimatedPositioned(
                    left: itemWidth * _index,
                    curve: Curves.easeOutCubic,
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      height: 35,
                      width: itemWidth,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: Consts.borderRadiusMax,
                      ),
                    ),
                  ),
                  itemRow,
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
