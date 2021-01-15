import 'package:flutter/material.dart';
import 'package:otraku/models/connection.dart';
import 'package:otraku/controllers/config.dart';
import 'package:otraku/tools/browse_indexer.dart';
import 'package:otraku/helpers/model_helper.dart';

class ConnectionsGrid extends StatefulWidget {
  final List<Connection> connections;
  final Function loadMore;
  final String preferredSubtitle;

  ConnectionsGrid({
    @required this.connections,
    @required this.loadMore,
    this.preferredSubtitle,
  });

  @override
  _ConnectionsGridState createState() => _ConnectionsGridState();
}

class _ConnectionsGridState extends State<ConnectionsGrid> {
  @override
  Widget build(BuildContext context) => SliverFixedExtentList(
        delegate: SliverChildBuilderDelegate(
          (_, index) {
            if (index == widget.connections.length - 5) widget.loadMore();
            return _MediaConnectionTile(
                widget.connections[index], widget.preferredSubtitle);
          },
          childCount: widget.connections.length,
        ),
        itemExtent: 110,
      );
}

class _MediaConnectionTile extends StatelessWidget {
  final Connection media;
  final String preferredSubtitle;

  _MediaConnectionTile(this.media, this.preferredSubtitle);

  @override
  Widget build(BuildContext context) {
    int index;
    if (preferredSubtitle == null)
      index = 0;
    else
      for (int i = 0; i < media.others.length; i++)
        if (media.others[i].subtitle == preferredSubtitle) {
          index = i;
          break;
        }

    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          borderRadius: Config.BORDER_RADIUS,
          color: Theme.of(context).primaryColor,
        ),
        child: Row(
          children: [
            Expanded(
              child: BrowseIndexer(
                id: media.id,
                browsable: media.browsable,
                tag: media.imageUrl,
                child: Container(
                  color: Colors.transparent,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 65,
                        height: 100,
                        child: ClipRRect(
                          child: FadeInImage.memoryNetwork(
                            image: media.imageUrl,
                            placeholder: ModelHelper.transparentImage,
                            fadeInDuration: Config.FADE_DURATION,
                            fit: BoxFit.cover,
                          ),
                          borderRadius:
                              BorderRadius.horizontal(left: Config.RADIUS),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: Config.PADDING,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Flexible(
                                child: Text(
                                  media.title,
                                  overflow: TextOverflow.fade,
                                  style: Theme.of(context).textTheme.bodyText1,
                                ),
                              ),
                              Text(
                                media.subtitle,
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
            if (index != null && media.others.length > index)
              Expanded(
                child: BrowseIndexer(
                  id: media.others[index].id,
                  browsable: media.others[index].browsable,
                  tag: media.others[index].imageUrl,
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
                                    media.others[index].title,
                                    overflow: TextOverflow.fade,
                                    textAlign: TextAlign.end,
                                    style:
                                        Theme.of(context).textTheme.bodyText1,
                                  ),
                                ),
                                Text(
                                  media.others[index].subtitle,
                                  style: Theme.of(context).textTheme.subtitle2,
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 65,
                          height: 100,
                          child: ClipRRect(
                            child: FadeInImage.memoryNetwork(
                              image: media.others[index].imageUrl,
                              placeholder: ModelHelper.transparentImage,
                              fadeInDuration: Config.FADE_DURATION,
                              fit: BoxFit.cover,
                            ),
                            borderRadius:
                                BorderRadius.horizontal(right: Config.RADIUS),
                          ),
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
