import 'package:flutter/material.dart';
import 'package:otraku/models/media_data.dart';
import 'package:otraku/providers/theming.dart';
import 'package:otraku/providers/view_config.dart';
import 'package:provider/provider.dart';

class InfoGrid extends StatelessWidget {
  final MediaData mediaObj;

  InfoGrid(this.mediaObj);

  @override
  Widget build(BuildContext context) {
    final palette = Provider.of<Theming>(context, listen: false).palette;

    List<Widget> row1 = [];
    List<Widget> row2 = [];
    for (int i = 0; i < mediaObj.info.length; i++) {
      if (i % 2 == 0) {
        row1
          ..add(_InfoTile(
            mediaObj.info[i].item1,
            mediaObj.info[i].item2,
            palette,
          ))
          ..add(const SizedBox(width: 10));
      } else {
        row2
          ..add(_InfoTile(
            mediaObj.info[i].item1,
            mediaObj.info[i].item2,
            palette,
          ))
          ..add(const SizedBox(width: 10));
      }
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: ViewConfig.PADDING,
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
  final Palette palette;

  const _InfoTile(this.heading, this.subtitle, this.palette);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: ViewConfig.RADIUS,
        color: palette.foreground,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 5,
          horizontal: 10,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              heading,
              style: palette.detail,
            ),
            Text(
              subtitle,
              style: palette.paragraph,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}
