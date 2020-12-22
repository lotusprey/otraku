import 'package:flutter/material.dart';
import 'package:otraku/services/config.dart';
import 'package:otraku/models/tile_config.dart';
import 'package:otraku/models/transparent_image.dart';

class BrowseTile extends StatelessWidget {
  final int id;
  final String text;
  final String imageUrl;
  final TileConfig tile;
  final bool preferIdTag;

  BrowseTile({
    @required this.id,
    @required this.text,
    @required this.imageUrl,
    @required this.tile,
    this.preferIdTag = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: tile.fullHeight,
      child: Column(
        children: [
          Hero(
            tag: preferIdTag ? id.toString() : imageUrl,
            child: ClipRRect(
              borderRadius: Config.BORDER_RADIUS,
              child: Container(
                width: tile.width,
                height: tile.imgHeight,
                color: tile.needsBackground
                    ? Theme.of(context).primaryColor
                    : null,
                child: FadeInImage.memoryNetwork(
                  placeholder: transparentImage,
                  image: imageUrl,
                  fadeInDuration: Config.FADE_DURATION,
                  fit: tile.fit,
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
