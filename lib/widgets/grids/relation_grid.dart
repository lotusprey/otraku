import 'package:flutter/material.dart';
import 'package:otraku/utils/consts.dart';
import 'package:otraku/common/relation.dart';
import 'package:otraku/widgets/link_tile.dart';
import 'package:otraku/widgets/cached_image.dart';
import 'package:otraku/widgets/grids/sliver_grid_delegates.dart';

class RelationGrid extends StatelessWidget {
  RelationGrid({
    required this.items,
    required this.placeholder,
    this.connections = const [],
  }) : assert(connections.isEmpty || items.length == connections.length);

  final String placeholder;
  final List<Relation> items;
  final List<Relation?> connections;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return SliverFillRemaining(child: Center(child: Text(placeholder)));
    }

    return SliverGrid(
      gridDelegate: SliverGridDelegateWithMinWidthAndFixedHeight(
        minWidth: connections.isEmpty ? 240 : 300,
        height: 115,
      ),
      delegate: SliverChildBuilderDelegate(
        childCount: items.length,
        connections.isNotEmpty
            ? (context, i) => _RelationTile(items[i], connections[i])
            : (context, i) => _RelationTile(items[i], null),
      ),
    );
  }
}

class _RelationTile extends StatelessWidget {
  const _RelationTile(this.item, this.connection);

  final Relation item;
  final Relation? connection;

  @override
  Widget build(BuildContext context) {
    late final Widget centerContent;
    if (connection != null) {
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
            id: connection!.id,
            discoverType: connection!.type,
            info: connection!.imageUrl,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Flexible(
                  child: Text(
                    connection!.title,
                    maxLines: 2,
                    textAlign: TextAlign.end,
                    overflow: TextOverflow.fade,
                  ),
                ),
                if (connection!.subtitle != null)
                  Text(
                    connection!.subtitle!,
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
              borderRadius: Consts.borderRadiusMin,
              child: CachedImage(item.imageUrl, width: 80),
            ),
          ),
          Expanded(
            child: Padding(padding: Consts.padding, child: centerContent),
          ),
          if (connection != null)
            LinkTile(
              key: ValueKey(connection!.id),
              id: connection!.id,
              discoverType: connection!.type,
              info: connection!.imageUrl,
              child: ClipRRect(
                borderRadius: Consts.borderRadiusMin,
                child: CachedImage(connection!.imageUrl, width: 80),
              ),
            ),
        ],
      ),
    );
  }
}
