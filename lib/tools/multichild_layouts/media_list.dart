import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:otraku/enums/score_format_enum.dart';
import 'package:otraku/pages/pushable/edit_entry_page.dart';
import 'package:otraku/providers/anime_collection.dart';
import 'package:otraku/providers/manga_collection.dart';
import 'package:otraku/providers/theming.dart';
import 'package:otraku/providers/view_config.dart';
import 'package:otraku/tools/media_indexer.dart';
import 'package:provider/provider.dart';

class MediaList extends StatelessWidget {
  final bool isAnimeCollection;
  final String scoreFormat;

  MediaList(this.isAnimeCollection, this.scoreFormat);

  @override
  Widget build(BuildContext context) {
    final palette = Provider.of<Theming>(context, listen: false).palette;
    final collection = isAnimeCollection
        ? Provider.of<AnimeCollection>(context)
        : Provider.of<MangaCollection>(context);
    final entries = collection.entries;

    if (entries == null) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'No ${collection.collectionName} Results',
                style: palette.smallTitle,
              ),
              IconButton(
                icon: const Icon(LineAwesomeIcons.retweet),
                color: palette.faded,
                iconSize: Palette.ICON_MEDIUM,
                onPressed: collection.clear,
              ),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: ViewConfig.PADDING,
      sliver: SliverFixedExtentList(
        delegate: SliverChildBuilderDelegate(
          (ctx, index) {
            final entry = entries[index];

            return ListTile(
              leading: Hero(
                tag: entry.mediaId.toString(),
                child: ClipRRect(
                  borderRadius: ViewConfig.RADIUS,
                  child: Container(
                    width: 50,
                    height: 50,
                    color: palette.foreground,
                    child: Image.network(entry.cover, fit: BoxFit.cover),
                  ),
                ),
              ),
              title: Text(
                entry.title,
                style: palette.paragraph,
              ),
              trailing: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  getWidgetFormScoreFormat(
                    palette,
                    scoreFormat,
                    entry.userData.score,
                  ),
                  Text(
                    '${entry.userData.progress}/${entry.progressMaxString}',
                    style: palette.detail,
                  ),
                ],
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 2),
              onTap: () => MediaIndexer.pushMedia(
                context,
                entry.mediaId,
                tag: entry.mediaId.toString(),
              ),
              onLongPress: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => EditEntryPage(entry.mediaId, (_) {}),
              )),
            );
          },
          childCount: entries.length,
        ),
        itemExtent: 60,
      ),
    );
  }
}
