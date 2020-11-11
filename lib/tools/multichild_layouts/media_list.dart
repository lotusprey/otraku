import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:otraku/enums/browsable_enum.dart';
import 'package:otraku/enums/enum_helper.dart';
import 'package:otraku/enums/score_format_enum.dart';
import 'package:otraku/enums/theme_enum.dart';
import 'package:otraku/models/sample_data/media_entry.dart';
import 'package:otraku/controllers/collections.dart';
import 'package:otraku/controllers/app_config.dart';
import 'package:otraku/tools/blossom_loader.dart';
import 'package:otraku/tools/media_indexer.dart';
import 'package:otraku/tools/overlays/dialogs.dart';
import 'package:provider/provider.dart';

class MediaList extends StatelessWidget {
  final bool isAnime;

  MediaList(this.isAnime);

  @override
  Widget build(BuildContext context) {
    final collection = Provider.of<Collections>(context).collection;

    if (collection == null) {
      if (Provider.of<Collections>(context, listen: false).fetching) {
        return const SliverFillRemaining(child: BlossomLoader());
      }

      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'No ${isAnime ? 'Anime' : 'Manga'}',
                style: Theme.of(context).textTheme.subtitle1,
              ),
            ],
          ),
        ),
      );
    }

    final entries = collection.entries;

    if (entries.length == 0) {
      return SliverFillRemaining(
        child: Center(
          child: Text(
            'No ${isAnime ? 'Anime' : 'Manga'} Results',
            style: Theme.of(context).textTheme.subtitle1,
          ),
        ),
      );
    }

    return SliverPadding(
      padding: AppConfig.PADDING,
      sliver: SliverFixedExtentList(
        delegate: SliverChildBuilderDelegate(
          (_, index) => _MediaListTile(entries[index], collection.scoreFormat),
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
  final String scoreFormat;

  _MediaListTile(this.media, this.scoreFormat);

  @override
  Widget build(BuildContext context) {
    return MediaIndexer(
      id: media.mediaId,
      itemType: Browsable.anime,
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
                  borderRadius: AppConfig.BORDER_RADIUS,
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
                                text: clarifyEnum(media.format),
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
                                  media.nextEpisode - 1 > media.progress)
                                TextSpan(
                                  text:
                                      ' • ${media.nextEpisode - 1 - media.progress} ep behind',
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
                      children: [
                        Flexible(
                          child: Center(
                            child: Text(
                              media.progress != media.progressMax
                                  ? '${media.progress} / ${media.progressMax ?? '?'}'
                                  : media.progress.toString(),
                              style: Theme.of(context).textTheme.subtitle2,
                            ),
                          ),
                        ),
                        Flexible(
                          child: Center(
                            child: getWidgetFormScoreFormat(
                              context,
                              scoreFormat,
                              media.score,
                            ),
                          ),
                        ),
                        Flexible(
                          child: Center(
                            child: media.repeat > 0
                                ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        FluentSystemIcons
                                            .ic_fluent_arrow_repeat_all_filled,
                                        size: Styles.ICON_SMALLER,
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        media.repeat.toString(),
                                        style: Theme.of(context)
                                            .textTheme
                                            .subtitle1,
                                      ),
                                    ],
                                  )
                                : null,
                          ),
                        ),
                        Flexible(
                          child: Center(
                            child: media.notes != null
                                ? IconButton(
                                    icon: const Icon(Icons.comment),
                                    onPressed: () => showDialog(
                                      context: context,
                                      builder: (_) => PopUpAnimation(
                                        TextDialog(
                                          title: 'Comment',
                                          text: media.notes,
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
