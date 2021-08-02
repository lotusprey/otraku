import 'package:flutter/material.dart';
import 'package:otraku/models/connection_model.dart';
import 'package:otraku/utils/config.dart';
import 'package:otraku/widgets/explore_indexer.dart';
import 'package:otraku/widgets/fade_image.dart';
import 'package:otraku/widgets/layouts/sliver_grid_delegates.dart';

class ConnectionsGrid extends StatefulWidget {
  final List<ConnectionModel> connections;
  final String? preferredSubtitle;

  ConnectionsGrid({
    required this.connections,
    this.preferredSubtitle,
  });

  @override
  _ConnectionsGridState createState() => _ConnectionsGridState();
}

class _ConnectionsGridState extends State<ConnectionsGrid> {
  @override
  Widget build(BuildContext context) => SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (_, index) => _MediaConnectionTile(
            widget.connections[index],
            widget.preferredSubtitle,
          ),
          childCount: widget.connections.length,
        ),
        gridDelegate: const SliverGridDelegateWithMinWidthAndFixedHeight(
          minWidth: 300,
          height: 110,
        ),
      );
}

class _MediaConnectionTile extends StatelessWidget {
  final ConnectionModel item;
  final String? preferredSubtitle;

  _MediaConnectionTile(this.item, this.preferredSubtitle);

  @override
  Widget build(BuildContext context) {
    int? index;
    if (preferredSubtitle == null)
      index = 0;
    else
      for (int i = 0; i < item.other.length; i++)
        if (item.other[i].subtitle == preferredSubtitle) {
          index = i;
          break;
        }

    return Align(
      alignment: Alignment.topCenter,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: Config.BORDER_RADIUS,
          color: Theme.of(context).primaryColor,
        ),
        child: Row(
          children: [
            Expanded(
              child: ExploreIndexer(
                id: item.id,
                browsable: item.type,
                imageUrl: item.imageUrl,
                child: Container(
                  color: Colors.transparent,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ClipRRect(
                        child: FadeImage(item.imageUrl, width: 75),
                        borderRadius:
                            BorderRadius.horizontal(left: Config.RADIUS),
                      ),
                      Expanded(
                        child: Padding(
                          padding: Config.PADDING,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  item.title,
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
                    ],
                  ),
                ),
              ),
            ),
            if (index != null && item.other.length > index)
              Expanded(
                child: ExploreIndexer(
                  id: item.other[index].id,
                  browsable: item.other[index].type,
                  imageUrl: item.other[index].imageUrl,
                  child: Container(
                    color: Colors.transparent,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: Config.PADDING,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Flexible(
                                  child: Text(
                                    item.other[index].title,
                                    overflow: TextOverflow.fade,
                                    textAlign: TextAlign.end,
                                  ),
                                ),
                                if (item.other[index].subtitle != null)
                                  Text(
                                    item.other[index].subtitle!,
                                    style:
                                        Theme.of(context).textTheme.subtitle2,
                                  ),
                              ],
                            ),
                          ),
                        ),
                        ClipRRect(
                          child: FadeImage(
                            item.other[index].imageUrl,
                            width: 75,
                          ),
                          borderRadius:
                              BorderRadius.horizontal(right: Config.RADIUS),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
