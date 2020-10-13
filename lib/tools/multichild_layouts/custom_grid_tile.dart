import 'package:flutter/material.dart';
import 'package:otraku/providers/view_config.dart';

class CustomGridTile extends StatelessWidget {
  final int mediaId;
  final String text;
  final String imageUrl;

  CustomGridTile({
    @required this.mediaId,
    @required this.text,
    @required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ViewConfig.tileConfiguration.tileWidth,
      height: ViewConfig.tileConfiguration.tileHeight,
      child: Column(
        children: [
          Hero(
            tag: imageUrl,
            child: ClipRRect(
              borderRadius: ViewConfig.BORDER_RADIUS,
              child: Container(
                height: ViewConfig.tileConfiguration.tileImgHeight,
                width: ViewConfig.tileConfiguration.tileWidth,
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
