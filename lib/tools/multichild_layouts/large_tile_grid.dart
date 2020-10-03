import 'package:flutter/material.dart';
import 'package:otraku/providers/explorable.dart';
import 'package:otraku/providers/view_config.dart';
import 'package:otraku/tools/media_indexer.dart';
import 'package:otraku/models/large_tile_configuration.dart';
import 'package:provider/provider.dart';

class LargeTileGrid extends StatelessWidget {
  final LargeTileConfiguration tileConfig;

  LargeTileGrid(this.tileConfig);

  @override
  Widget build(BuildContext context) {
    final type = Provider.of<Explorable>(context).type;
    final results = Provider.of<Explorable>(context).results;

    if (results.length == 0) {
      return SliverFillRemaining(
        child: Center(
          child: Text(
            'No results',
            style: Theme.of(context).textTheme.subtitle1,
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.only(left: 10, right: 10, top: 15),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (_, index) => MediaIndexer(
            itemType: type,
            id: results[index].id,
            child: _SimpleGridTile(
              mediaId: results[index].id,
              text: results[index].text,
              imageUrl: results[index].imageUrl,
              width: tileConfig.tileWidth,
              height: tileConfig.tileHeight,
              imageHeight: tileConfig.tileImgHeight,
            ),
          ),
          childCount: results.length,
        ),
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: tileConfig.tileWidth,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: tileConfig.tileWHRatio,
        ),
      ),
    );
  }
}

class _SimpleGridTile extends StatelessWidget {
  final int mediaId;
  final String text;
  final String imageUrl;
  final double width;
  final double height;
  final double imageHeight;

  _SimpleGridTile({
    @required this.mediaId,
    @required this.text,
    @required this.imageUrl,
    @required this.width,
    @required this.height,
    @required this.imageHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      child: Column(
        children: <Widget>[
          Hero(
            tag: mediaId,
            child: ClipRRect(
              borderRadius: ViewConfig.RADIUS,
              child: Container(
                height: imageHeight,
                width: width,
                color: Theme.of(context).primaryColor,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Flexible(
            child: Text(
              text,
              overflow: TextOverflow.fade,
              style: Theme.of(context).textTheme.subtitle1,
            ),
          ),
        ],
      ),
    );
  }
}
