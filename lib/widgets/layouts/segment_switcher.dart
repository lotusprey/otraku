import 'package:flutter/material.dart';
import 'package:otraku/constants/consts.dart';

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
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              child: Center(
                child: Text(
                  widget.items[i],
                  overflow: TextOverflow.ellipsis,
                  style: i != _index
                      ? Theme.of(context).textTheme.headline2
                      : Theme.of(context).textTheme.headline2?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                ),
              ),
              onTap: () {
                if (_index == i) return;
                setState(() => _index = i);
                widget.onChanged(i);
              },
            ),
          ),
      ],
    );

    return Flexible(
      child: LayoutBuilder(
        builder: (context, constraints) {
          double itemWidth = (constraints.maxWidth - 20) / widget.items.length;
          if (itemWidth > 150) itemWidth = 150;

          return Container(
            height: Consts.tapTargetSize,
            width: itemWidth * widget.items.length,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.background,
              borderRadius: Consts.borderRadiusMax,
              boxShadow: [
                BoxShadow(
                  blurRadius: 5,
                  color: Theme.of(context)
                      .colorScheme
                      .surfaceVariant
                      .withAlpha(100),
                ),
              ],
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                AnimatedPositioned(
                  left: itemWidth * _index,
                  curve: Curves.easeOutCubic,
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    width: itemWidth,
                    height: Consts.tapTargetSize,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: Consts.borderRadiusMax,
                      border: Border.all(
                        width: 5,
                        color: Theme.of(context).colorScheme.background,
                      ),
                    ),
                  ),
                ),
                itemRow,
              ],
            ),
          );
        },
      ),
    );
  }
}

class CompactSegmentSwitcher extends StatefulWidget {
  CompactSegmentSwitcher({
    required this.items,
    required this.current,
    required this.onChanged,
  });

  final int current;
  final List<String> items;
  final void Function(int) onChanged;

  @override
  State<CompactSegmentSwitcher> createState() => _CompactSegmentSwitcherState();
}

class _CompactSegmentSwitcherState extends State<CompactSegmentSwitcher> {
  late int _index = widget.current;

  @override
  void didUpdateWidget(covariant CompactSegmentSwitcher oldWidget) {
    super.didUpdateWidget(oldWidget);
    _index = widget.current;
  }

  @override
  Widget build(BuildContext context) {
    final itemRow = Row(
      children: [
        for (int i = 0; i < widget.items.length; i++)
          Flexible(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
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
                      ? Theme.of(context).textTheme.headline2
                      : Theme.of(context).textTheme.headline2?.copyWith(
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
          child: Container(
            height: 35,
            width: constraints.maxWidth,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
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
        );
      },
    );
  }
}
