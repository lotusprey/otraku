import 'package:flutter/material.dart';
import 'package:otraku/enums/score_format_enum.dart';
import 'package:otraku/models/list_entry.dart';
import 'package:otraku/providers/theming.dart';
import 'package:otraku/tools/media_indexer.dart';
import 'package:provider/provider.dart';

class MediaList extends StatelessWidget {
  final List<ListEntry> entries;
  final String scoreFormat;
  final String name;

  MediaList({this.entries, this.scoreFormat, this.name = ''});

  @override
  Widget build(BuildContext context) {
    final palette = Provider.of<Theming>(context, listen: false).palette;
    final radius = BorderRadius.circular(5);

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (ctx, index) {
          final entry = entries[index];
          final tag = '$name${entry.id}';

          return ListTile(
            leading: Hero(
              tag: tag,
              child: ClipRRect(
                borderRadius: radius,
                child: Container(
                  width: 50,
                  height: 50,
                  color: palette.primary,
                  child: Image.network(entry.cover, fit: BoxFit.cover),
                ),
              ),
            ),
            title: Text(
              entry.title,
              style: palette.titleSmall,
            ),
            trailing: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                getWidgetFormScoreFormat(palette, scoreFormat, entry.score),
                Text('${entry.progress}/${entry.totalEpCount ?? '?'}',
                    style: palette.detail),
              ],
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 2),
            onTap: () => MediaIndexer.pushMedia(
              context,
              entry.id,
              tag: tag,
            ),
          );
        },
        childCount: entries.length,
      ),
    );
  }
}
