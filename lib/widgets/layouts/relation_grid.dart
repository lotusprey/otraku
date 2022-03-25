import 'package:flutter/material.dart';
import 'package:otraku/constants/consts.dart';
import 'package:otraku/models/relation_model.dart';
import 'package:otraku/widgets/explore_indexer.dart';
import 'package:otraku/widgets/fade_image.dart';
import 'package:otraku/widgets/layouts/sliver_grid_delegates.dart';

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
      return SliverFillRemaining(
        child: Center(
          child: Text(
            placeholder,
            style: Theme.of(context).textTheme.subtitle1,
          ),
        ),
      );

    return SliverGrid(
      delegate: SliverChildBuilderDelegate(
        connections.isNotEmpty
            ? (_, i) => _RelationTile(items[i], connections[i])
            : (_, i) => _RelationTile(items[i], null),
        childCount: items.length,
      ),
      gridDelegate: const SliverGridDelegateWithMinWidthAndFixedHeight(
        minWidth: 300,
        height: 115,
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
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: Consts.BORDER_RAD_MIN,
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Row(
        children: [
          ExploreIndexer(
            id: item.id,
            explorable: item.type,
            imageUrl: item.imageUrl,
            child: ClipRRect(
              child: FadeImage(item.imageUrl, width: 80),
              borderRadius: Consts.BORDER_RAD_MIN,
            ),
          ),
          Expanded(
            child: Padding(
              padding: Consts.PADDING,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: ExploreIndexer(
                      id: item.id,
                      explorable: item.type,
                      imageUrl: item.imageUrl,
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
                  if (connection != null) ...[
                    const SizedBox(height: 3),
                    ExploreIndexer(
                      id: connection!.id,
                      explorable: connection!.type,
                      imageUrl: connection!.imageUrl,
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
                ],
              ),
            ),
          ),
          if (connection != null)
            ExploreIndexer(
              id: connection!.id,
              explorable: connection!.type,
              imageUrl: connection!.imageUrl,
              child: ClipRRect(
                child: FadeImage(connection!.imageUrl, width: 80),
                borderRadius: Consts.BORDER_RAD_MIN,
              ),
            ),
        ],
      ),
    );
  }
}
