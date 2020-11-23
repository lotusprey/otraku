import 'package:flutter/material.dart';
import 'package:otraku/models/page_data/media_data_old.dart';
import 'package:otraku/controllers/config.dart';

class InfoGrid extends StatelessWidget {
  final MediaDataOld mediaObj;

  InfoGrid(this.mediaObj);

  @override
  Widget build(BuildContext context) {
    List<Widget> row1 = [];
    List<Widget> row2 = [];
    for (int i = 0; i < mediaObj.info.length; i++) {
      if (i % 2 == 0) {
        row1
          ..add(_InfoTile(mediaObj.info[i].item1, mediaObj.info[i].item2))
          ..add(const SizedBox(width: 10));
      } else {
        row2
          ..add(_InfoTile(mediaObj.info[i].item1, mediaObj.info[i].item2))
          ..add(const SizedBox(width: 10));
      }
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: Config.PADDING,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: row1,
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: row2,
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String heading;
  final String subtitle;

  const _InfoTile(this.heading, this.subtitle);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: Config.BORDER_RADIUS,
        color: Theme.of(context).primaryColor,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 5,
          horizontal: 10,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              heading,
              style: Theme.of(context).textTheme.subtitle1,
            ),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyText1,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}
