import 'package:flutter/material.dart';
import 'package:otraku/constants/consts.dart';
import 'package:otraku/models/relation_model.dart';
import 'package:otraku/widgets/explore_indexer.dart';
import 'package:otraku/widgets/fade_image.dart';
import 'package:otraku/widgets/grids/sliver_grid_delegates.dart';

class RelationGrid extends StatelessWidget {
  RelationGrid({
    required this.items,
    required this.placeholder,
    this.connections = const [],
  }) : assert(connections.isEmpty || items.length == connections.length);

  final String placeholder;
  final List<RelationModel> items;
  final List<RelationModel?> connections;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty)
      return SliverFillRemaining(child: Center(child: Text(placeholder)));

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
  _RelationTile(this.item, this.connection);

  final RelationModel item;
  final RelationModel? connection;

  @override
  Widget build(BuildContext context) {
    late final Widget centerContent;
    if (connection != null)
      centerContent = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: ExploreIndexer(
              id: item.id,
              explorable: item.type,
              text: item.imageUrl,
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
                      style: Theme.of(context).textTheme.subtitle2,
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 3),
          ExploreIndexer(
            id: connection!.id,
            explorable: connection!.type,
            text: connection!.imageUrl,
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
                    style: Theme.of(context).textTheme.subtitle2,
                  ),
              ],
            ),
          ),
        ],
      );
    else
      centerContent = ExploreIndexer(
        id: item.id,
        explorable: item.type,
        text: item.imageUrl,
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
                style: Theme.of(context).textTheme.subtitle2,
              ),
          ],
        ),
      );

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: Consts.borderRadiusMin,
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Row(
        children: [
          ExploreIndexer(
            id: item.id,
            explorable: item.type,
            text: item.imageUrl,
            child: ClipRRect(
              child: FadeImage(item.imageUrl, width: 80),
              borderRadius: Consts.borderRadiusMin,
            ),
          ),
          Expanded(
            child: Padding(padding: Consts.padding, child: centerContent),
          ),
          if (connection != null)
            ExploreIndexer(
              id: connection!.id,
              explorable: connection!.type,
              text: connection!.imageUrl,
              child: ClipRRect(
                child: FadeImage(connection!.imageUrl, width: 80),
                borderRadius: Consts.borderRadiusMin,
              ),
            ),
        ],
      ),
    );
  }
}
