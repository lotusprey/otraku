import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/controllers/collection_controller.dart';
import 'package:otraku/constants/explorable.dart';
import 'package:otraku/utils/convert.dart';
import 'package:otraku/constants/score_format.dart';
import 'package:otraku/models/list_entry_model.dart';
import 'package:otraku/constants/consts.dart';
import 'package:otraku/utils/settings.dart';
import 'package:otraku/widgets/fade_image.dart';
import 'package:otraku/widgets/layouts/sliver_grid_delegates.dart';
import 'package:otraku/widgets/loaders.dart/loader.dart';
import 'package:otraku/widgets/explore_indexer.dart';
import 'package:otraku/widgets/overlays/dialogs.dart';

class CollectionGrid extends StatelessWidget {
  CollectionGrid(this.ctrlTag);

  final String ctrlTag;

  @override
  Widget build(BuildContext context) {
    final isMe =
        ctrlTag == '${Settings().id}true' || ctrlTag == '${Settings().id}false';
    final sidePadding = MediaQuery.of(context).size.width > 1020
        ? (MediaQuery.of(context).size.width - 1000) / 2.0
        : 10.0;

    return GetBuilder<CollectionController>(
      id: CollectionController.ID_BODY,
      tag: ctrlTag,
      builder: (ctrl) {
        if (ctrl.isLoading)
          return SliverFillRemaining(child: Center(child: const Loader()));

        if (ctrl.entries.isEmpty)
          return SliverFillRemaining(
            child: Center(
              child: Text(
                ctrl.isEmpty
                    ? 'No ${ctrl.ofAnime ? 'Anime' : 'Manga'}'
                    : 'No ${ctrl.ofAnime ? 'Anime' : 'Manga'} Results',
                style: Theme.of(context).textTheme.subtitle1,
              ),
            ),
          );

        return SliverPadding(
          padding:
              EdgeInsets.only(left: sidePadding, right: sidePadding, top: 15),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (_, i) => _CollectionGridTile(ctrl.entries[i], ctrl, isMe),
              childCount: ctrl.entries.length,
            ),
            gridDelegate: const SliverGridDelegateWithMinWidthAndFixedHeight(
              minWidth: 350,
              height: 150,
            ),
          ),
        );
      },
    );
  }
}

class _CollectionGridTile extends StatefulWidget {
  _CollectionGridTile(this.model, this.ctrl, this.isMe);

  final ListEntryModel model;
  final CollectionController ctrl;
  final bool isMe;

  @override
  State<_CollectionGridTile> createState() => _CollectionGridTileState();
}

class _CollectionGridTileState extends State<_CollectionGridTile> {
  @override
  Widget build(BuildContext context) {
    final details = <TextSpan>[];
    if (widget.model.format != null)
      details.add(TextSpan(text: Convert.clarifyEnum(widget.model.format)));
    if (widget.model.airingAt != null)
      details.add(TextSpan(
        text: '${details.isEmpty ? "" : ' • '}'
            'Ep ${widget.model.nextEpisode} in '
            '${Convert.timeUntilTimestamp(widget.model.airingAt)}',
      ));
    if (widget.model.nextEpisode != null &&
        widget.model.nextEpisode! - 1 > widget.model.progress)
      details.add(TextSpan(
        text: '${details.isEmpty ? "" : ' • '}'
            '${widget.model.nextEpisode! - 1 - widget.model.progress} ep behind',
        style: Theme.of(context)
            .textTheme
            .bodyText1
            ?.copyWith(fontSize: Consts.FONT_SMALL),
      ));

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: Consts.BORDER_RADIUS,
      ),
      child: ExploreIndexer(
        id: widget.model.mediaId,
        explorable: Explorable.anime,
        imageUrl: widget.model.cover,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: widget.model.mediaId,
              child: ClipRRect(
                child: Container(
                  width: 95,
                  color: Theme.of(context).colorScheme.surface,
                  child: FadeImage(widget.model.cover),
                ),
                borderRadius: Consts.BORDER_RADIUS,
              ),
            ),
            Expanded(
              child: Padding(
                padding: Consts.PADDING,
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
                            child: Text(
                              widget.model.titles[0],
                              overflow: TextOverflow.fade,
                            ),
                          ),
                          const SizedBox(height: 5),
                          RichText(
                            text: TextSpan(
                              style: Theme.of(context).textTheme.subtitle2,
                              children: details,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 5,
                      margin: const EdgeInsets.symmetric(vertical: 3),
                      decoration: BoxDecoration(
                        borderRadius: Consts.BORDER_RADIUS,
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.primary,
                            Theme.of(context).colorScheme.primary,
                            Theme.of(context).colorScheme.background,
                            Theme.of(context).colorScheme.background,
                          ],
                          stops: [
                            0.0,
                            widget.model.progressPercent(),
                            widget.model.progressPercent(),
                            1.0,
                          ],
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Tooltip(message: 'Score', child: _buildScore(context)),
                        if (widget.model.repeat > 0)
                          Tooltip(
                            message: 'Repeats',
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Ionicons.repeat,
                                  size: Consts.ICON_SMALL,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  widget.model.repeat.toString(),
                                  style: Theme.of(context).textTheme.subtitle2,
                                ),
                              ],
                            ),
                          )
                        else
                          const SizedBox(),
                        if (widget.model.notes != null)
                          IconButton(
                            tooltip: 'Comment',
                            constraints: const BoxConstraints(
                              maxHeight: Consts.ICON_SMALL,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            icon: const Icon(
                              Ionicons.chatbox,
                              size: Consts.ICON_SMALL,
                            ),
                            onPressed: () => showPopUp(
                              context,
                              TextDialog(
                                title: 'Comment',
                                text: widget.model.notes!,
                              ),
                            ),
                          )
                        else
                          const SizedBox(),
                        _Progress(
                          model: widget.model,
                          increment: widget.isMe
                              ? () {
                                  setState(() => widget.model.progress++);
                                  widget.ctrl.updateProgress(widget.model);
                                }
                              : null,
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
    if (widget.model.score == 0) return const SizedBox();

    switch (widget.ctrl.scoreFormat) {
      case ScoreFormat.POINT_3:
        if (widget.model.score == 3)
          return const Icon(
            Icons.sentiment_very_satisfied,
            size: Consts.ICON_SMALL,
          );

        if (widget.model.score == 2)
          return const Icon(Icons.sentiment_neutral, size: Consts.ICON_SMALL);

        return const Icon(
          Icons.sentiment_very_dissatisfied,
          size: Consts.ICON_SMALL,
        );
      case ScoreFormat.POINT_5:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star_rounded, size: Consts.ICON_SMALL),
            const SizedBox(width: 5),
            Text(
              widget.model.score.toStringAsFixed(0),
              style: Theme.of(context).textTheme.subtitle2,
            ),
          ],
        );
      case ScoreFormat.POINT_10_DECIMAL:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star_half_rounded, size: Consts.ICON_SMALL),
            const SizedBox(width: 5),
            Text(
              widget.model.score.toStringAsFixed(
                widget.model.score.truncate() == widget.model.score ? 0 : 1,
              ),
              style: Theme.of(context).textTheme.subtitle2,
            ),
          ],
        );
      default:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star_half_rounded, size: Consts.ICON_SMALL),
            const SizedBox(width: 5),
            Text(
              widget.model.score.toStringAsFixed(0),
              style: Theme.of(context).textTheme.subtitle2,
            ),
          ],
        );
    }
  }
}

class _Progress extends StatelessWidget {
  _Progress({required this.model, required this.increment});

  final ListEntryModel model;
  final Function()? increment;

  @override
  Widget build(BuildContext context) {
    final text = Text(
      model.progress == model.progressMax
          ? model.progress.toString()
          : '${model.progress}/${model.progressMax ?? "?"}',
      style: Theme.of(context).textTheme.subtitle2,
    );

    if (increment == null || model.progress == model.progressMax)
      return Tooltip(message: 'Progress', child: text);

    return TextButton(
      style: ButtonStyle(
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        minimumSize: MaterialStateProperty.all(const Size(0, 20)),
        maximumSize: MaterialStateProperty.all(const Size.fromHeight(20)),
        padding: MaterialStateProperty.all(const EdgeInsets.only(left: 5)),
      ),
      onPressed: () {
        if (model.progressMax == null ||
            model.progress < model.progressMax! - 1)
          increment!();
        else
          ExploreIndexer.openEditView(model.mediaId, context);
      },
      child: Tooltip(
        message: 'Increment Progress',
        child: Row(
          children: [
            text,
            const SizedBox(width: 5),
            Icon(
              Ionicons.add_outline,
              size: Consts.ICON_SMALL,
              color: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}
