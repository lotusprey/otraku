import 'package:flutter/material.dart';
import 'package:otraku/models/media_object.dart';
import 'package:otraku/tools/overlays/dialogs.dart';

class MediaTop extends StatelessWidget {
  final MediaObject mediaObj;
  final double coverWidth;
  final double coverHeight;

  MediaTop({
    this.mediaObj,
    this.coverWidth,
    this.coverHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: coverHeight + 20,
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: <Widget>[
          GestureDetector(
            child: Container(
              width: coverWidth,
              height: coverHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: mediaObj.cover,
              ),
            ),
            onTap: () => showDialog(
              context: context,
              builder: (ctx) => PopUpAnimation(
                ImageTextDialog(
                  text: mediaObj.title,
                  style: Theme.of(context).textTheme.headline4,
                  image: mediaObj.cover,
                ),
              ),
              barrierDismissible: true,
            ),
          ),
          const SizedBox(width: 30),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  mediaObj.title,
                  style: Theme.of(context).textTheme.headline4,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
                if (mediaObj.nextEpisode != null)
                  Text(
                    'Ep ${mediaObj.nextEpisode} in ${mediaObj.timeUntilAiring}',
                    style: Theme.of(context).textTheme.headline5,
                    maxLines: 2,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
