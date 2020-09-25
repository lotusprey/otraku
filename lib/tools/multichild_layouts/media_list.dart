import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:otraku/enums/score_format_enum.dart';
import 'package:otraku/pages/pushable/edit_entry_page.dart';
import 'package:otraku/providers/anime_collection.dart';
import 'package:otraku/providers/manga_collection.dart';
import 'package:otraku/providers/view_config.dart';
import 'package:otraku/tools/media_indexer.dart';
import 'package:provider/provider.dart';

class MediaList extends StatelessWidget {
  final bool isAnimeCollection;
  final String scoreFormat;

  MediaList(this.isAnimeCollection, this.scoreFormat);

  @override
  Widget build(BuildContext context) {
    final collection = isAnimeCollection
        ? Provider.of<AnimeCollection>(context)
        : Provider.of<MangaCollection>(context);
    if (collection.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'No ${collection.collectionName} Results',
                style: Theme.of(context).textTheme.subtitle1,
              ),
              IconButton(
                icon: const Icon(LineAwesomeIcons.retweet),
                onPressed: collection.clear,
              ),
            ],
          ),
        ),
      );
    }

    final entries = collection.entries;

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
                    color: Theme.of(context).primaryColor,
                    child: Image.network(entry.cover, fit: BoxFit.cover),
                  ),
                ),
              ),
              title: Text(
                entry.title,
                style: Theme.of(context).textTheme.bodyText1,
              ),
              trailing: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  getWidgetFormScoreFormat(
                    context,
                    scoreFormat,
                    entry.userData.score,
                  ),
                  Text(
                    '${entry.userData.progress}/${entry.progressMaxString}',
                    style: Theme.of(context).textTheme.subtitle1,
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
