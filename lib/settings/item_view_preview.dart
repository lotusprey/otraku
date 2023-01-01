import 'package:flutter/material.dart';
import 'package:otraku/settings/visual_preview_card.dart';

class ItemViewPreview extends StatefulWidget {
  const ItemViewPreview({required this.current, required this.onChanged});

  final int current;
  final void Function(int) onChanged;

  @override
  State<ItemViewPreview> createState() => _ItemViewPreviewState();
}

class _ItemViewPreviewState extends State<ItemViewPreview> {
  late int _current = widget.current;

  @override
  void didUpdateWidget(covariant ItemViewPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    _current = widget.current;
  }

  @override
  Widget build(BuildContext context) {
    const borderRadius = BorderRadius.all(Radius.circular(5));

    return SizedBox(
      height: 190,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 5),
        children: [
          VisualPreviewCard(
            name: 'Detailed List',
            active: _current == 0,
            scheme: null,
            onTap: () {
              if (_current == 0) return;
              setState(() => _current = 0);
              widget.onChanged(_current);
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (int i = 0; i < 3; i++) ...[
                  Container(
                    height: 35,
                    alignment: Alignment.centerLeft,
                    margin: const EdgeInsets.only(bottom: 5),
                    decoration: BoxDecoration(
                      borderRadius: borderRadius,
                      color: Theme.of(context).colorScheme.surfaceVariant,
                    ),
                    child: Container(
                      width: 30,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: borderRadius,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          VisualPreviewCard(
            name: 'Simple Grid',
            active: _current == 1,
            scheme: null,
            onTap: () {
              if (_current == 1) return;
              setState(() => _current = 1);
              widget.onChanged(_current);
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (int i = 0; i < 3; i++) ...[
                  Container(
                    height: 40,
                    margin: const EdgeInsets.only(bottom: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        for (int i = 0; i < 3; i++) ...[
                          Container(
                            width: 30,
                            decoration: BoxDecoration(
                              borderRadius: borderRadius,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
