import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/modules/collection/collection_models.dart';
import 'package:otraku/modules/discover/discover_models.dart';
import 'package:otraku/modules/edit/edit_providers.dart';
import 'package:otraku/modules/media/media_constants.dart';
import 'package:otraku/common/utils/convert.dart';
import 'package:otraku/common/utils/consts.dart';
import 'package:otraku/modules/edit/edit_view.dart';
import 'package:otraku/common/widgets/cached_image.dart';
import 'package:otraku/common/widgets/link_tile.dart';
import 'package:otraku/common/widgets/overlays/dialogs.dart';
import 'package:otraku/common/widgets/overlays/sheets.dart';
import 'package:otraku/common/widgets/text_rail.dart';

const _TILE_HEIGHT = 140.0;

class CollectionList extends StatelessWidget {
  const CollectionList({
    required this.items,
    required this.scoreFormat,
    required this.onProgressUpdate,
  });

  final List<Entry> items;
  final ScoreFormat scoreFormat;

  /// Called when a tile's progress gets incremented.
  /// If `null` the increment button won't appear, so this
  /// should only be `null` when viewing other users' collections.
  final void Function(Entry, List<String>)? onProgressUpdate;

  @override
  Widget build(BuildContext context) {
    return SliverFixedExtentList(
      delegate: SliverChildBuilderDelegate(
        (_, i) => _Tile(items[i], scoreFormat, onProgressUpdate),
        childCount: items.length,
      ),
      // The added pixels are for the bottom margin.
      itemExtent: _TILE_HEIGHT + 10,
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile(this.entry, this.scoreFormat, this.onProgressUpdate);

  final Entry entry;
  final ScoreFormat scoreFormat;
  final void Function(Entry, List<String>)? onProgressUpdate;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: LinkTile(
        key: ValueKey(entry.mediaId),
        id: entry.mediaId,
        discoverType: DiscoverType.anime,
        info: entry.imageUrl,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: entry.mediaId,
              child: ClipRRect(
                borderRadius: Consts.borderRadiusMin,
                child: Container(
                  width: _TILE_HEIGHT / Consts.coverHtoWRatio,
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  child: CachedImage(entry.imageUrl),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
                child: _TileContent(entry, scoreFormat, onProgressUpdate),
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
  const _TileContent(this.item, this.scoreFormat, this.onProgressUpdate);

  final Entry item;
  final ScoreFormat scoreFormat;
  final void Function(Entry, List<String>)? onProgressUpdate;

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
                      style: Theme.of(context).textTheme.labelSmall,
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
              style: Theme.of(context).textTheme.labelSmall,
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
              style: Theme.of(context).textTheme.labelSmall,
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
              style: Theme.of(context).textTheme.labelSmall,
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
      style: Theme.of(context).textTheme.labelSmall,
    );

    if (widget.onProgressUpdate == null || item.progress == item.progressMax) {
      return Tooltip(message: 'Progress', child: text);
    }

    return TextButton(
      style: TextButton.styleFrom(
        minimumSize: const Size(0, 40),
        padding: const EdgeInsets.only(left: 5),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      onPressed: () async {
        if (item.progressMax != null &&
            item.progress >= item.progressMax! - 1) {
          showSheet(context, EditView(EditTag(item.mediaId, true)));
          return;
        }

        setState(() => item.progress++);
        final result = await updateProgress(item.mediaId, item.progress);

        if (result is! List<String>) {
          if (mounted) {
            showPopUp(
              context,
              ConfirmationDialog(
                title: 'Could not update progress',
                content: result.toString(),
              ),
            );
          }
          return;
        }

        widget.onProgressUpdate?.call(item, result);
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
