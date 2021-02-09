import 'package:flutter/material.dart';
import 'package:otraku/controllers/config.dart';
import 'package:otraku/models/tile_config.dart';
import 'package:otraku/helpers/fn_helper.dart';

class BrowseTile extends StatelessWidget {
  final int id;
  final String text;
  final String imageUrl;
  final TileConfig tile;

  BrowseTile({
    @required this.id,
    @required this.text,
    @required this.imageUrl,
    @required this.tile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: tile.fullHeight,
      child: Column(
        children: [
          Hero(
            tag: id,
            child: ClipRRect(
              borderRadius: Config.BORDER_RADIUS,
              child: Container(
                width: double.infinity,
                height: tile.imgHeight,
                color: tile.needsBackground
                    ? Theme.of(context).primaryColor
                    : null,
                child: FadeInImage.memoryNetwork(
                  placeholder: FnHelper.transparentImage,
                  image: imageUrl,
                  fadeInDuration: Config.FADE_DURATION,
                  fit: tile.fit,
                  imageErrorBuilder: (_, err, stackTrace) => const SizedBox(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 5),
          Flexible(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              style: Theme.of(context).textTheme.subtitle1,
            ),
          ),
        ],
      ),
    );
  }
}
