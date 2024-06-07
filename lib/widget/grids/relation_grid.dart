import 'package:flutter/material.dart';
import 'package:otraku/model/relation.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/widget/link_tile.dart';
import 'package:otraku/widget/cached_image.dart';
import 'package:otraku/widget/grids/sliver_grid_delegates.dart';

class RelationGrid extends StatelessWidget {
  const RelationGrid(this.items);

  final List<(Relation, Relation?)> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SliverToBoxAdapter();

    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithMinWidthAndFixedHeight(
        minWidth: 300,
        height: 115,
      ),
      delegate: SliverChildBuilderDelegate(
        childCount: items.length,
        (context, i) => _RelationTile(items[i].$1, items[i].$2),
      ),
    );
  }
}

class SingleRelationGrid extends StatelessWidget {
  const SingleRelationGrid(this.items);

  final List<Relation> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SliverToBoxAdapter();

    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithMinWidthAndFixedHeight(
        minWidth: 240,
        height: 115,
      ),
      delegate: SliverChildBuilderDelegate(
        childCount: items.length,
        (context, i) => _RelationTile(items[i], null),
      ),
    );
  }
}

class _RelationTile extends StatelessWidget {
  const _RelationTile(this.item, this.secondary);

  final Relation item;
  final Relation? secondary;

  @override
  Widget build(BuildContext context) {
    late final Widget centerContent;
    if (secondary != null) {
      centerContent = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: LinkTile(
              id: item.id,
              discoverType: item.type,
              info: item.imageUrl,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    child: Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.fade,
                    ),
                  ),
                  if (item.subtitle != null)
                    Text(
                      item.subtitle!,
                      maxLines: 2,
                      overflow: TextOverflow.fade,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 3),
          LinkTile(
            id: secondary!.id,
            discoverType: secondary!.type,
            info: secondary!.imageUrl,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Flexible(
                  child: Text(
                    secondary!.title,
                    maxLines: 2,
                    textAlign: TextAlign.end,
                    overflow: TextOverflow.fade,
                  ),
                ),
                if (secondary!.subtitle != null)
                  Text(
                    secondary!.subtitle!,
                    maxLines: 2,
                    overflow: TextOverflow.fade,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
              ],
            ),
          ),
        ],
      );
    } else {
      centerContent = LinkTile(
        id: item.id,
        discoverType: item.type,
        info: item.imageUrl,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(child: Text(item.title, overflow: TextOverflow.fade)),
            if (item.subtitle != null)
              Text(
                item.subtitle!,
                maxLines: 4,
                overflow: TextOverflow.fade,
                style: Theme.of(context).textTheme.labelSmall,
              ),
          ],
        ),
      );
    }

    return Card(
      child: Row(
        children: [
          LinkTile(
            id: item.id,
            discoverType: item.type,
            info: item.imageUrl,
            child: ClipRRect(
              borderRadius: Theming.borderRadiusSmall,
              child: CachedImage(item.imageUrl, width: 80),
            ),
          ),
          Expanded(
            child: Padding(padding: Theming.paddingAll, child: centerContent),
          ),
          if (secondary != null)
            LinkTile(
              key: ValueKey(secondary!.id),
              id: secondary!.id,
              discoverType: secondary!.type,
              info: secondary!.imageUrl,
              child: ClipRRect(
                borderRadius: Theming.borderRadiusSmall,
                child: CachedImage(secondary!.imageUrl, width: 80),
              ),
            ),
        ],
      ),
    );
  }
}
