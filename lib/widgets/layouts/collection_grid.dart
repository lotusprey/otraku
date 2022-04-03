import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/constants/explorable.dart';
import 'package:otraku/utils/convert.dart';
import 'package:otraku/constants/score_format.dart';
import 'package:otraku/models/list_entry_model.dart';
import 'package:otraku/constants/consts.dart';
import 'package:otraku/views/edit_view.dart';
import 'package:otraku/widgets/fade_image.dart';
import 'package:otraku/widgets/layouts/sliver_grid_delegates.dart';
import 'package:otraku/widgets/explore_indexer.dart';
import 'package:otraku/widgets/overlays/dialogs.dart';
import 'package:otraku/widgets/overlays/sheets.dart';

const _TILE_HEIGHT = 140.0;

class CollectionGrid extends StatelessWidget {
  CollectionGrid({
    required this.items,
    required this.scoreFormat,
    required this.updateProgress,
  });

  final List<ListEntryModel> items;
  final ScoreFormat scoreFormat;
  final void Function(ListEntryModel)? updateProgress;

  @override
  Widget build(BuildContext context) {
    return SliverGrid(
      delegate: SliverChildBuilderDelegate(
        (_, i) => _Tile(items[i], scoreFormat, updateProgress),
        childCount: items.length,
      ),
      gridDelegate: const SliverGridDelegateWithMinWidthAndFixedHeight(
        minWidth: 350,
        height: _TILE_HEIGHT,
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  _Tile(this.model, this.scoreFormat, this.updateProgress);

  final ListEntryModel model;
  final ScoreFormat scoreFormat;
  final void Function(ListEntryModel)? updateProgress;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: Consts.BORDER_RAD_MIN,
      ),
      child: ExploreIndexer(
        id: model.mediaId,
        explorable: Explorable.anime,
        imageUrl: model.cover,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: model.mediaId,
              child: ClipRRect(
                borderRadius: Consts.BORDER_RAD_MIN,
                child: Container(
                  width: _TILE_HEIGHT / Consts.COVER_HW_RATIO,
                  color: Theme.of(context).colorScheme.surface,
                  child: FadeImage(model.cover),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: Consts.PADDING,
                child: _TileContent(model, scoreFormat, updateProgress),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The content is a [StatefulWidget], as it
/// needs to update when the progress increments.
class _TileContent extends StatefulWidget {
  _TileContent(this.model, this.scoreFormat, this.updateProgress);

  final ListEntryModel model;
  final ScoreFormat scoreFormat;
  final void Function(ListEntryModel)? updateProgress;

  @override
  State<_TileContent> createState() => __TileContentState();
}

class __TileContentState extends State<_TileContent> {
  @override
  Widget build(BuildContext context) {
    final model = widget.model;
    double progressPercent = 1;
    if (model.progressMax != null)
      progressPercent = model.progress / model.progressMax!;
    else if (model.nextEpisode != null)
      progressPercent = model.progress / (model.nextEpisode! - 1);

    return Column(
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
                  children: _buildDetails(),
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 5,
          margin: const EdgeInsets.symmetric(vertical: 3),
          decoration: BoxDecoration(
            borderRadius: Consts.BORDER_RAD_MIN,
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.surfaceVariant,
                Theme.of(context).colorScheme.surfaceVariant,
                Theme.of(context).colorScheme.background,
                Theme.of(context).colorScheme.background,
              ],
              stops: [0.0, progressPercent, progressPercent, 1.0],
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
                    const SizedBox(width: 5),
                    const Icon(
                      Ionicons.repeat,
                      size: Consts.ICON_SMALL,
                    ),
                    const SizedBox(width: 3),
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
                  maxHeight: Consts.ICON_SMALL + 10,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 5),
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
            _buildProgressButton(),
          ],
        ),
      ],
    );
  }

  List<TextSpan> _buildDetails() {
    final ts = <TextSpan>[];

    if (widget.model.format != null)
      ts.add(TextSpan(text: Convert.clarifyEnum(widget.model.format)));

    if (widget.model.airingAt != null)
      ts.add(TextSpan(
        text: '${ts.isEmpty ? "" : ' • '}'
            'Ep ${widget.model.nextEpisode} in '
            '${Convert.timeUntilTimestamp(widget.model.airingAt)}',
      ));

    if (widget.model.nextEpisode != null &&
        widget.model.nextEpisode! - 1 > widget.model.progress)
      ts.add(TextSpan(
        text: '${ts.isEmpty ? "" : ' • '}'
            '${widget.model.nextEpisode! - 1 - widget.model.progress} ep behind',
        style: Theme.of(context)
            .textTheme
            .bodyText1
            ?.copyWith(fontSize: Consts.FONT_SMALL),
      ));

    return ts;
  }

  Widget _buildScore(BuildContext context) {
    if (widget.model.score == 0) return const SizedBox();

    switch (widget.scoreFormat) {
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
            const SizedBox(width: 3),
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
            const SizedBox(width: 3),
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
            const SizedBox(width: 3),
            Text(
              widget.model.score.toStringAsFixed(0),
              style: Theme.of(context).textTheme.subtitle2,
            ),
          ],
        );
    }
  }

  Widget _buildProgressButton() {
    final model = widget.model;
    final text = Text(
      model.progress == model.progressMax
          ? model.progress.toString()
          : '${model.progress}/${model.progressMax ?? "?"}',
      style: Theme.of(context).textTheme.subtitle2,
    );

    if (widget.updateProgress == null || model.progress == model.progressMax)
      return Tooltip(message: 'Progress', child: text);

    return TextButton(
      style: ButtonStyle(
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        minimumSize: MaterialStateProperty.all(const Size(0, 30)),
        maximumSize: MaterialStateProperty.all(const Size.fromHeight(30)),
        padding: MaterialStateProperty.all(const EdgeInsets.only(left: 5)),
      ),
      onPressed: () {
        if (model.progressMax == null ||
            model.progress < model.progressMax! - 1) {
          setState(() => model.progress++);
          widget.updateProgress!(model);
        } else
          showSheet(context, EditView(model.mediaId, complete: true));
      },
      child: Tooltip(
        message: 'Increment Progress',
        child: Row(
          children: [
            text,
            const SizedBox(width: 3),
            Icon(
              Ionicons.add_outline,
              size: Consts.ICON_SMALL,
              color: Theme.of(context).colorScheme.surfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
