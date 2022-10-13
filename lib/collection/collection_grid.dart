import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/collection/collection_models.dart';
import 'package:otraku/discover/discover_models.dart';
import 'package:otraku/media/media_constants.dart';
import 'package:otraku/utils/convert.dart';
import 'package:otraku/utils/consts.dart';
import 'package:otraku/edit/edit_view.dart';
import 'package:otraku/widgets/fade_image.dart';
import 'package:otraku/widgets/grids/sliver_grid_delegates.dart';
import 'package:otraku/widgets/link_tile.dart';
import 'package:otraku/widgets/overlays/dialogs.dart';
import 'package:otraku/widgets/overlays/sheets.dart';
import 'package:otraku/widgets/text_rail.dart';

const _TILE_HEIGHT = 140.0;

class CollectionGrid extends StatelessWidget {
  const CollectionGrid({
    required this.items,
    required this.scoreFormat,
    required this.updateProgress,
  });

  final List<Entry> items;
  final ScoreFormat scoreFormat;
  final void Function(Entry)? updateProgress;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (_, i) => _Tile(items[i], scoreFormat, updateProgress),
          childCount: items.length,
        ),
        gridDelegate: const SliverGridDelegateWithMinWidthAndFixedHeight(
          minWidth: 350,
          height: _TILE_HEIGHT,
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile(this.model, this.scoreFormat, this.updateProgress);

  final Entry model;
  final ScoreFormat scoreFormat;
  final void Function(Entry)? updateProgress;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: LinkTile(
        id: model.mediaId,
        discoverType: DiscoverType.anime,
        info: model.imageUrl,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: model.mediaId,
              child: ClipRRect(
                borderRadius: Consts.borderRadiusMin,
                child: Container(
                  width: _TILE_HEIGHT / Consts.coverHtoWRatio,
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  child: FadeImage(model.imageUrl),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
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
  const _TileContent(this.item, this.scoreFormat, this.updateProgress);

  final Entry item;
  final ScoreFormat scoreFormat;
  final void Function(Entry)? updateProgress;

  @override
  State<_TileContent> createState() => __TileContentState();
}

class __TileContentState extends State<_TileContent> {
  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    double progressPercent = 0;
    if (item.progressMax != null) {
      progressPercent = item.progress / item.progressMax!;
    } else if (item.nextEpisode != null) {
      progressPercent = item.progress / (item.nextEpisode! - 1);
    } else if (item.progress > 0) {
      progressPercent = 1;
    }

    final textRailItems = <String, bool>{};
    if (widget.item.format != null) {
      textRailItems[Convert.clarifyEnum(widget.item.format)!] = false;
    }
    if (widget.item.airingAt != null) {
      textRailItems['Ep ${widget.item.nextEpisode} in '
          '${Convert.timeUntilTimestamp(widget.item.airingAt)}'] = false;
    }
    if (widget.item.nextEpisode != null &&
        widget.item.nextEpisode! - 1 > widget.item.progress) {
      textRailItems['${widget.item.nextEpisode! - 1 - widget.item.progress}'
          ' ep behind'] = true;
    }

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
                  widget.item.titles[0],
                  overflow: TextOverflow.fade,
                ),
              ),
              const SizedBox(height: 5),
              TextRail(textRailItems),
            ],
          ),
        ),
        Container(
          height: 5,
          margin: const EdgeInsets.symmetric(vertical: 3),
          decoration: BoxDecoration(
            borderRadius: Consts.borderRadiusMin,
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.onSurfaceVariant,
                Theme.of(context).colorScheme.onSurfaceVariant,
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
            if (widget.item.repeat > 0)
              Tooltip(
                message: 'Repeats',
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Ionicons.repeat, size: Consts.iconSmall),
                    const SizedBox(width: 3),
                    Text(
                      widget.item.repeat.toString(),
                      style: Theme.of(context).textTheme.subtitle2,
                    ),
                  ],
                ),
              )
            else
              const SizedBox(),
            if (widget.item.notes != null)
              SizedBox(
                height: 40,
                child: Tooltip(
                  message: 'Comment',
                  child: InkResponse(
                    radius: 10,
                    child: const Icon(Ionicons.chatbox, size: Consts.iconSmall),
                    onTap: () => showPopUp(
                      context,
                      TextDialog(
                        title: 'Comment',
                        text: widget.item.notes!,
                      ),
                    ),
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

  Widget _buildScore(BuildContext context) {
    if (widget.item.score == 0) return const SizedBox();

    switch (widget.scoreFormat) {
      case ScoreFormat.POINT_3:
        if (widget.item.score == 3) {
          return const Icon(
            Icons.sentiment_very_satisfied,
            size: Consts.iconSmall,
          );
        }

        if (widget.item.score == 2) {
          return const Icon(Icons.sentiment_neutral, size: Consts.iconSmall);
        }

        return const Icon(
          Icons.sentiment_very_dissatisfied,
          size: Consts.iconSmall,
        );
      case ScoreFormat.POINT_5:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star_rounded, size: Consts.iconSmall),
            const SizedBox(width: 3),
            Text(
              widget.item.score.toStringAsFixed(0),
              style: Theme.of(context).textTheme.subtitle2,
            ),
          ],
        );
      case ScoreFormat.POINT_10_DECIMAL:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star_half_rounded, size: Consts.iconSmall),
            const SizedBox(width: 3),
            Text(
              widget.item.score.toStringAsFixed(
                widget.item.score.truncate() == widget.item.score ? 0 : 1,
              ),
              style: Theme.of(context).textTheme.subtitle2,
            ),
          ],
        );
      default:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star_half_rounded, size: Consts.iconSmall),
            const SizedBox(width: 3),
            Text(
              widget.item.score.toStringAsFixed(0),
              style: Theme.of(context).textTheme.subtitle2,
            ),
          ],
        );
    }
  }

  Widget _buildProgressButton() {
    final item = widget.item;
    final text = Text(
      item.progress == item.progressMax
          ? item.progress.toString()
          : '${item.progress}/${item.progressMax ?? "?"}',
      style: Theme.of(context).textTheme.subtitle2,
    );

    if (widget.updateProgress == null || item.progress == item.progressMax) {
      return Tooltip(message: 'Progress', child: text);
    }

    return TextButton(
      style: TextButton.styleFrom(
        minimumSize: const Size(0, 40),
        padding: const EdgeInsets.only(left: 5),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      onPressed: () {
        if (item.progressMax == null || item.progress < item.progressMax! - 1) {
          setState(() => item.progress++);
          widget.updateProgress!(item);
        } else {
          showSheet(context, EditView(item.mediaId, complete: true));
        }
      },
      child: Tooltip(
        message: 'Increment Progress',
        child: Row(
          children: [
            text,
            const SizedBox(width: 3),
            const Icon(Ionicons.add_outline, size: Consts.iconSmall),
          ],
        ),
      ),
    );
  }
}
