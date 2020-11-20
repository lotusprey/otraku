import 'package:flutter/material.dart';
import 'package:otraku/models/sample_data/connection.dart';
import 'package:otraku/controllers/config.dart';
import 'package:otraku/tools/media_indexer.dart';

class MediaConnectionGrid extends StatefulWidget {
  final List<Connection> media;
  final Function loadMore;

  MediaConnectionGrid(this.media, this.loadMore);

  @override
  _MediaConnectionGridState createState() => _MediaConnectionGridState();
}

class _MediaConnectionGridState extends State<MediaConnectionGrid> {
  @override
  Widget build(BuildContext context) => SliverFixedExtentList(
        delegate: SliverChildBuilderDelegate(
          (_, index) {
            if (index == widget.media.length - 5) widget.loadMore();

            return _MediaConnectionTile(widget.media[index]);
          },
          childCount: widget.media.length,
        ),
        itemExtent: 110,
      );
}

class _MediaConnectionTile extends StatelessWidget {
  final Connection media;

  _MediaConnectionTile(this.media);

  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.topCenter,
        child: Container(
          height: 100,
          decoration: BoxDecoration(
            borderRadius: Config.BORDER_RADIUS,
            color: Theme.of(context).primaryColor,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: MediaIndexer(
                  id: media.id,
                  itemType: media.browsable,
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
                            child: Image.network(media.imageUrl,
                                fit: BoxFit.cover),
                            borderRadius: Config.BORDER_RADIUS,
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(5),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Flexible(
                                  child: Text(
                                    media.title,
                                    overflow: TextOverflow.fade,
                                    style:
                                        Theme.of(context).textTheme.bodyText1,
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
              if (media.others.length > 0)
                Expanded(
                  child: MediaIndexer(
                    id: media.others[0].id,
                    itemType: media.others[0].browsable,
                    tag: media.others[0].imageUrl,
                    child: Container(
                      color: Colors.transparent,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(5),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Flexible(
                                    child: Text(
                                      media.others[0].title,
                                      overflow: TextOverflow.fade,
                                      textAlign: TextAlign.end,
                                      style:
                                          Theme.of(context).textTheme.bodyText1,
                                    ),
                                  ),
                                  Text(
                                    media.others[0].subtitle,
                                    style:
                                        Theme.of(context).textTheme.subtitle2,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 65,
                            height: 100,
                            child: ClipRRect(
                              child: Image.network(
                                media.others[0].imageUrl,
                                fit: BoxFit.cover,
                              ),
                              borderRadius: Config.BORDER_RADIUS,
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
