import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/controllers/collection_controller.dart';
import 'package:otraku/enums/explorable.dart';
import 'package:otraku/utils/convert.dart';
import 'package:otraku/enums/score_format.dart';
import 'package:otraku/enums/themes.dart';
import 'package:otraku/models/list_entry_model.dart';
import 'package:otraku/utils/config.dart';
import 'package:otraku/widgets/fade_image.dart';
import 'package:otraku/widgets/loaders.dart/loader.dart';
import 'package:otraku/widgets/explore_indexer.dart';
import 'package:otraku/widgets/overlays/dialogs.dart';

class MediaList extends StatelessWidget {
  final String? collectionTag;

  MediaList(this.collectionTag);

  @override
  Widget build(BuildContext context) {
    final collectionCtrl = Get.find<CollectionController>(tag: collectionTag);
    final sidePadding = MediaQuery.of(context).size.width > 620
        ? (MediaQuery.of(context).size.width - 600) / 2.0
        : 10.0;

    return Obx(() {
      if (collectionCtrl.isFullyEmpty) {
        if (collectionCtrl.isLoading)
          return const SliverFillRemaining(child: Center(child: Loader()));

        return SliverFillRemaining(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'No ${collectionCtrl.ofAnime ? 'Anime' : 'Manga'}',
                  style: Theme.of(context).textTheme.subtitle1,
                ),
              ],
            ),
          ),
        );
      }

      if (collectionCtrl.isEmpty)
        return SliverFillRemaining(
          child: Center(
            child: Text(
              'No ${collectionCtrl.ofAnime ? 'Anime' : 'Manga'} Results',
              style: Theme.of(context).textTheme.subtitle1,
            ),
          ),
        );

      final entries = collectionCtrl.entries;

      return SliverPadding(
        padding: EdgeInsets.only(
          left: sidePadding,
          right: sidePadding,
          top: 15,
        ),
        sliver: SliverFixedExtentList(
          delegate: SliverChildBuilderDelegate(
            (_, i) => _MediaListTile(entries[i], collectionCtrl),
            childCount: entries.length,
          ),
          itemExtent: 150,
        ),
      );
    });
  }
}

class _MediaListTile extends StatelessWidget {
  final ListEntryModel entry;
  final CollectionController collectionCtrl;

  _MediaListTile(this.entry, this.collectionCtrl);

  @override
  Widget build(BuildContext context) {
    final format = Convert.clarifyEnum(entry.format);
    final timeUntilAiring = entry.airingAt == null
        ? null
        : '${format == null ? "" : ' • '}'
            'Ep ${entry.nextEpisode} in '
            '${Convert.timeUntilTimestamp(entry.airingAt)}';
    final episodesBehind =
        entry.nextEpisode == null || entry.nextEpisode! - 1 <= entry.progress
            ? null
            : '${format == null && entry.airingAt == null ? "" : ' • '}'
                '${entry.nextEpisode! - 1 - entry.progress} ep behind';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: Config.BORDER_RADIUS,
      ),
      child: ExploreIndexer(
        id: entry.mediaId,
        browsable: Explorable.anime,
        imageUrl: entry.cover,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: entry.mediaId,
              child: ClipRRect(
                child: Container(
                  width: 95,
                  color: Theme.of(context).primaryColor,
                  child: FadeImage(entry.cover),
                ),
                borderRadius: Config.BORDER_RADIUS,
              ),
            ),
            Expanded(
              child: Padding(
                padding: Config.PADDING,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Flexible(
                            child:
                                Text(entry.title!, overflow: TextOverflow.fade),
                          ),
                          const SizedBox(height: 5),
                          RichText(
                            text: TextSpan(
                              style: Theme.of(context).textTheme.subtitle2,
                              children: [
                                TextSpan(text: format),
                                TextSpan(text: timeUntilAiring),
                                TextSpan(
                                  text: episodesBehind,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText1
                                      ?.copyWith(fontSize: Style.FONT_SMALL),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 5,
                      margin: const EdgeInsets.symmetric(vertical: 3),
                      decoration: BoxDecoration(
                        borderRadius: Config.BORDER_RADIUS,
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).disabledColor,
                            Theme.of(context).disabledColor,
                            Theme.of(context).backgroundColor,
                            Theme.of(context).backgroundColor,
                          ],
                          stops: [
                            0.0,
                            entry.progressPercent(),
                            entry.progressPercent(),
                            1.0,
                          ],
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Tooltip(message: 'Score', child: _buildScore(context)),
                        if (entry.repeat > 0)
                          Tooltip(
                            message: 'Repeats',
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Ionicons.repeat,
                                  size: Style.ICON_SMALL,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  entry.repeat.toString(),
                                  style: Theme.of(context).textTheme.subtitle2,
                                ),
                              ],
                            ),
                          )
                        else
                          const SizedBox(),
                        if (entry.notes != null)
                          IconButton(
                            tooltip: 'Comment',
                            constraints: const BoxConstraints(
                              maxHeight: Style.ICON_SMALL,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            icon: const Icon(
                              Ionicons.chatbox,
                              size: Style.ICON_SMALL,
                            ),
                            onPressed: () => showPopUp(
                              context,
                              TextDialog(
                                title: 'Comment',
                                text: entry.notes!,
                              ),
                            ),
                          )
                        else
                          const SizedBox(),
                        _ProgressButton(
                          entry,
                          collectionCtrl.updateProgress,
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

  Widget _buildScore(BuildContext context) {
    if (entry.score == 0) return const SizedBox();

    switch (collectionCtrl.scoreFormat) {
      case ScoreFormat.POINT_3:
        if (entry.score == 3)
          return const Icon(
            Icons.sentiment_very_satisfied,
            size: Style.ICON_SMALL,
          );

        if (entry.score == 2)
          return const Icon(Icons.sentiment_neutral, size: Style.ICON_SMALL);

        return const Icon(
          Icons.sentiment_very_dissatisfied,
          size: Style.ICON_SMALL,
        );
      case ScoreFormat.POINT_5:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star_rounded, size: Style.ICON_SMALL),
            const SizedBox(width: 5),
            Text(
              entry.score.toStringAsFixed(0),
              style: Theme.of(context).textTheme.subtitle2,
            ),
          ],
        );
      case ScoreFormat.POINT_10_DECIMAL:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star_half_rounded, size: Style.ICON_SMALL),
            const SizedBox(width: 5),
            Text(
              entry.score.toStringAsFixed(
                entry.score.truncate() == entry.score ? 0 : 1,
              ),
              style: Theme.of(context).textTheme.subtitle2,
            ),
          ],
        );
      default:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star_half_rounded, size: Style.ICON_SMALL),
            const SizedBox(width: 5),
            Text(
              entry.score.toStringAsFixed(0),
              style: Theme.of(context).textTheme.subtitle2,
            ),
          ],
        );
    }
  }
}

class _ProgressButton extends StatelessWidget {
  final ListEntryModel entry;
  final void Function(ListEntryModel) increment;
  _ProgressButton(this.entry, this.increment);

  @override
  Widget build(BuildContext context) {
    if (entry.progress == entry.progressMax)
      return Tooltip(
        message: 'Progress',
        child: Text(
          entry.progress.toString(),
          style: Theme.of(context).textTheme.subtitle2,
        ),
      );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => increment(entry),
      child: Row(
        children: [
          Tooltip(
            message: 'Progress',
            child: Text(
              '${entry.progress}/${entry.progressMax ?? "?"}',
              style: Theme.of(context).textTheme.subtitle2,
            ),
          ),
          const SizedBox(width: 5),
          Tooltip(
            message: 'Increment Progress',
            child: const Icon(Ionicons.add_outline, size: Style.ICON_SMALL),
          ),
        ],
      ),
    );
  }
}
