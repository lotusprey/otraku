import 'package:flutter/material.dart';
import 'package:otraku/controllers/config.dart';
import 'package:otraku/models/transparent_image.dart';

class LargeGridTile extends StatelessWidget {
  final int mediaId;
  final String text;
  final String imageUrl;

  LargeGridTile({
    @required this.mediaId,
    @required this.text,
    @required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Config.tileConfig.tileWidth,
      height: Config.tileConfig.tileHeight,
      child: Column(
        children: [
          Hero(
            tag: imageUrl,
            child: ClipRRect(
              borderRadius: Config.BORDER_RADIUS,
              child: Container(
                height: Config.tileConfig.tileImgHeight,
                color: Theme.of(context).primaryColor,
                child: FadeInImage.memoryNetwork(
                  placeholder: transparentImage,
                  image: imageUrl,
                  fadeInDuration: Config.FADE_DURATION,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Flexible(
            child: Hero(
              tag: text,
              child: Text(
                text,
                overflow: TextOverflow.fade,
                style: Theme.of(context).textTheme.subtitle1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
