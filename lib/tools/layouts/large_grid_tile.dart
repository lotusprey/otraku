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
      height: Config.tileConfig.fullHeight,
      child: Column(
        children: [
          Hero(
            tag: imageUrl,
            child: ClipRRect(
              borderRadius: Config.BORDER_RADIUS,
              child: Container(
                width: Config.tileConfig.width,
                height: Config.tileConfig.imgHeight,
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
