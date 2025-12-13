import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:otraku/extension/build_context_extension.dart';
import 'package:otraku/extension/card_extension.dart';
import 'package:otraku/feature/staff/staff_item_model.dart';
import 'package:otraku/util/routes.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/widget/cached_image.dart';
import 'package:otraku/widget/grid/sliver_grid_delegates.dart';

class StaffItemGrid extends StatelessWidget {
  const StaffItemGrid(this.items, {required this.highContrast});

  final List<StaffItem> items;
  final bool highContrast;

  @override
  Widget build(BuildContext context) {
    final lineHeight = context.lineHeight(TextTheme.of(context).bodyMedium!);
    final textHeight = lineHeight * 2 + 10;

    return SliverGrid(
      gridDelegate: SliverGridDelegateWithMinWidthAndExtraHeight(
        minWidth: 100,
        extraHeight: textHeight,
        rawHWRatio: Theming.coverHtoWRatio,
      ),
      delegate: SliverChildBuilderDelegate(
        (_, i) => _Tile(items[i], highContrast, textHeight),
        childCount: items.length,
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile(this.item, this.highContrast, this.textHeight);

  final StaffItem item;
  final bool highContrast;
  final double textHeight;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: Theming.borderRadiusSmall,
      onTap: () => context.push(Routes.staff(item.id, item.imageUrl)),
      child: CardExtension.highContrast(highContrast)(
        child: Column(
          crossAxisAlignment: .stretch,
          children: [
            Expanded(
              child: Hero(
                tag: item.id,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Theming.radiusSmall),
                  child: CachedImage(item.imageUrl),
                ),
              ),
            ),
            SizedBox(
              height: textHeight,
              child: Padding(
                padding: const .all(5),
                child: Text(item.name, maxLines: 2, overflow: .ellipsis),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
