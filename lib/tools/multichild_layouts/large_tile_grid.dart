import 'package:flutter/material.dart';
import 'package:otraku/providers/explorable_media.dart';
import 'package:otraku/providers/theming.dart';
import 'package:otraku/providers/view_config.dart';
import 'package:otraku/tools/media_indexer.dart';
import 'package:otraku/models/large_tile_configuration.dart';
import 'package:provider/provider.dart';

class LargeTileGrid extends StatelessWidget {
  final LargeTileConfiguration tileConfig;
  final Palette palette;

  LargeTileGrid(this.tileConfig, this.palette);

  @override
  Widget build(BuildContext context) {
    final data = Provider.of<ExplorableMedia>(context).data;

    if (data.length == 0) {
      return SliverFillRemaining(
        child: Center(
          child: Text(
            'No results',
            style: palette.smallTitle,
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.only(left: 10, right: 10, top: 15),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (_, index) => MediaIndexer(
            mediaId: data[index]['id'],
            child: _SimpleGridTile(
              mediaId: data[index]['id'],
              title: data[index]['title'],
              imageUrl: data[index]['imageUrl'],
              width: tileConfig.tileWidth,
              height: tileConfig.tileHeight,
              imageHeight: tileConfig.tileImgHeight,
            ),
          ),
          childCount: data.length,
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
  final String title;
  final String imageUrl;
  final double width;
  final double height;
  final double imageHeight;

  _SimpleGridTile({
    @required this.mediaId,
    @required this.title,
    @required this.imageUrl,
    @required this.width,
    @required this.height,
    @required this.imageHeight,
  });

  @override
  Widget build(BuildContext context) {
    final palette = Provider.of<Theming>(context, listen: false).palette;

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
                color: palette.primary,
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
              title,
              overflow: TextOverflow.fade,
              style: palette.smallTitle,
            ),
          ),
        ],
      ),
    );
  }
}
