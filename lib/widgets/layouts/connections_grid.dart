import 'package:flutter/material.dart';
import 'package:otraku/models/connection_model.dart';
import 'package:otraku/constants/consts.dart';
import 'package:otraku/widgets/explore_indexer.dart';
import 'package:otraku/widgets/fade_image.dart';
import 'package:otraku/widgets/layouts/sliver_grid_delegates.dart';

class ConnectionsGrid extends StatelessWidget {
  ConnectionsGrid({
    required this.connections,
    this.preferredSubtitle,
  });

  final List<ConnectionModel> connections;
  final String? preferredSubtitle;

  @override
  Widget build(BuildContext context) => SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (_, i) => _ConnectionTile(connections[i], preferredSubtitle),
          childCount: connections.length,
        ),
        gridDelegate: const SliverGridDelegateWithMinWidthAndFixedHeight(
          minWidth: 300,
          height: 115,
        ),
      );
}

class _ConnectionTile extends StatelessWidget {
  _ConnectionTile(this.item, this.preferredSubtitle);

  final ConnectionModel item;
  final String? preferredSubtitle;

  @override
  Widget build(BuildContext context) {
    int index = 0;
    if (preferredSubtitle != null)
      for (int i = 0; i < item.other.length; i++)
        if (item.other[i].subtitle == preferredSubtitle) {
          index = i;
          break;
        }

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
                  if (item.other.length > index) ...[
                    const SizedBox(height: 3),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Flexible(
                          child: Text(
                            item.other[index].title,
                            maxLines: 2,
                            textAlign: TextAlign.end,
                            overflow: TextOverflow.fade,
                          ),
                        ),
                        if (item.other[index].subtitle != null)
                          Text(
                            item.other[index].subtitle!,
                            maxLines: 2,
                            overflow: TextOverflow.fade,
                            style: Theme.of(context).textTheme.subtitle2,
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (item.other.length > index)
            ExploreIndexer(
              id: item.other[index].id,
              explorable: item.other[index].type,
              imageUrl: item.other[index].imageUrl,
              child: ClipRRect(
                child: FadeImage(item.other[index].imageUrl, width: 80),
                borderRadius: Consts.BORDER_RAD_MIN,
              ),
            ),
        ],
      ),
    );
  }
}
