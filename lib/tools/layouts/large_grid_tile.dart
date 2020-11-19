import 'package:flutter/material.dart';
import 'package:otraku/controllers/app_config.dart';

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
      width: AppConfig.tileConfig.tileWidth,
      height: AppConfig.tileConfig.tileHeight,
      child: Column(
        children: [
          Hero(
            tag: imageUrl,
            child: ClipRRect(
              borderRadius: AppConfig.BORDER_RADIUS,
              child: Container(
                height: AppConfig.tileConfig.tileImgHeight,
                width: AppConfig.tileConfig.tileWidth,
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
