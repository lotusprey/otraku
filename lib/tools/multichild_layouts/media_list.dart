import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:otraku/enums/browsable_enum.dart';
import 'package:otraku/enums/enum_helper.dart';
import 'package:otraku/enums/score_format_enum.dart';
import 'package:otraku/models/sample_data/media_entry.dart';
import 'package:otraku/providers/anime_collection.dart';
import 'package:otraku/providers/design.dart';
import 'package:otraku/providers/manga_collection.dart';
import 'package:otraku/providers/view_config.dart';
import 'package:otraku/tools/media_indexer.dart';
import 'package:otraku/tools/overlays/dialogs.dart';
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
      if (collection.isLoading) {
        return const SliverFillRemaining();
      }

      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'No ${collection.collectionName}',
                style: Theme.of(context).textTheme.subtitle1,
              ),
              IconButton(
                icon: const Icon(
                    FluentSystemIcons.ic_fluent_arrow_repeat_all_filled),
                onPressed: collection.clear,
              ),
            ],
          ),
        ),
      );
    }

    final entries = collection.entries;

    if (entries == null) {
      return SliverFillRemaining(
        child: Center(
          child: Text(
            'No ${collection.collectionName} Results',
            style: Theme.of(context).textTheme.subtitle1,
          ),
        ),
      );
    }

    return SliverPadding(
      padding: ViewConfig.PADDING,
      sliver: SliverFixedExtentList(
        delegate: SliverChildBuilderDelegate(
          (_, index) => _MediaListTile(
            entries[index],
            isAnimeCollection,
            scoreFormat,
          ),
          childCount: entries.length,
        ),
        itemExtent: 150,
      ),
    );
  }
}

class _MediaListTile extends StatelessWidget {
  static const _space = SizedBox(height: 5);

  final MediaEntry media;
  final bool isAnime;
  final String scoreFormat;

  _MediaListTile(this.media, this.isAnime, this.scoreFormat);

  @override
  Widget build(BuildContext context) {
    return MediaIndexer(
      id: media.mediaId,
      itemType: isAnime ? Browsable.anime : Browsable.manga,
      tag: media.cover,
      child: Container(
        color: Theme.of(context).backgroundColor,
        child: Row(
          children: [
            Hero(
              tag: media.cover,
              child: SizedBox(
                height: 140,
                width: 95,
                child: ClipRRect(
                  child: Image.network(media.cover, fit: BoxFit.cover),
                  borderRadius: ViewConfig.BORDER_RADIUS,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Flexible(
                          child: Text(
                            media.title,
                            style: Theme.of(context).textTheme.bodyText1,
                            overflow: TextOverflow.fade,
                          ),
                        ),
                        _space,
                        RichText(
                          text: TextSpan(
                            style: Theme.of(context).textTheme.subtitle2,
                            children: [
                              TextSpan(
                                text: clarifyEnum(media.userData.format),
                              ),
                              if (media.timeUntilAiring != null)
                                TextSpan(
                                  text:
                                      ' • Ep ${media.nextEpisode} in ${media.timeUntilAiring}',
                                  style: TextStyle(
                                    color: Theme.of(context).accentColor,
                                  ),
                                ),
                              if (media.nextEpisode != null &&
                                  media.nextEpisode - 1 >
                                      media.userData.progress)
                                TextSpan(
                                  text:
                                      ' • ${media.nextEpisode - 1 - media.userData.progress} ep behind',
                                  style: TextStyle(
                                    color: Theme.of(context).errorColor,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        SizedBox(
                          width: 50,
                          child: Center(
                            child: Text(
                              media.userData.progress !=
                                      media.userData.progressMax
                                  ? '${media.userData.progress} / ${media.userData.progressMax ?? '?'}'
                                  : media.userData.progress.toString(),
                              style: Theme.of(context).textTheme.subtitle2,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 50,
                          child: Center(
                            child: getWidgetFormScoreFormat(
                              context,
                              scoreFormat,
                              media.userData.score,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 50,
                          child: Center(
                            child: media.userData.repeat > 0
                                ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        media.userData.repeat.toString(),
                                        style: Theme.of(context)
                                            .textTheme
                                            .subtitle1,
                                      ),
                                      const Icon(
                                        FluentSystemIcons
                                            .ic_fluent_arrow_repeat_all_filled,
                                        size: Design.ICON_SMALLER,
                                      ),
                                    ],
                                  )
                                : null,
                          ),
                        ),
                        SizedBox(
                          width: 30,
                          child: Center(
                            child: media.userData.notes != null
                                ? IconButton(
                                    icon: const Icon(Icons.comment),
                                    onPressed: () => showDialog(
                                      context: context,
                                      builder: (_) => PopUpAnimation(
                                        TextDialog(
                                          title: 'Comment',
                                          text: media.userData.notes,
                                        ),
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
