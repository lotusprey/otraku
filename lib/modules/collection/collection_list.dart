import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/common/utils/extensions.dart';
import 'package:otraku/common/widgets/entry_labels.dart';
import 'package:otraku/modules/collection/collection_models.dart';
import 'package:otraku/modules/discover/discover_models.dart';
import 'package:otraku/modules/media/media_constants.dart';
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
    required this.onProgressUpdated,
  });

  final List<Entry> items;
  final ScoreFormat scoreFormat;
  final Future<String?> Function(Entry)? onProgressUpdated;

  @override
  Widget build(BuildContext context) {
    return SliverFixedExtentList(
      delegate: SliverChildBuilderDelegate(
        (_, i) => _Tile(items[i], scoreFormat, onProgressUpdated),
        childCount: items.length,
      ),
      // The added pixels are for the bottom margin.
      itemExtent: _TILE_HEIGHT + 10,
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile(this.entry, this.scoreFormat, this.onProgressUpdated);

  final Entry entry;
  final ScoreFormat scoreFormat;
  final Future<String?> Function(Entry)? onProgressUpdated;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: LinkTile(
        key: ValueKey(entry.mediaId),
        id: entry.mediaId,
        discoverType: DiscoverType.Anime,
        info: entry.imageUrl,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: entry.mediaId,
              child: ClipRRect(
                borderRadius: const BorderRadius.horizontal(
                  left: Consts.radiusMin,
                ),
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
                child: _TileContent(entry, scoreFormat, onProgressUpdated),
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
  const _TileContent(this.item, this.scoreFormat, this.onProgressUpdated);

  final Entry item;
  final ScoreFormat scoreFormat;
  final Future<String?> Function(Entry)? onProgressUpdated;

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
      textRailItems[widget.item.format!.noScreamingSnakeCase] = false;
    }

    if (widget.item.airingAt != null) {
      final key =
          'Ep ${widget.item.nextEpisode} in ${widget.item.airingAt!.timeUntil}';
      textRailItems[key] = false;
    }

    if (widget.item.nextEpisode != null &&
        widget.item.nextEpisode! - 1 > widget.item.progress) {
      final key =
          '${widget.item.nextEpisode! - 1 - widget.item.progress} ep behind';
      textRailItems[key] = true;
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
            ScoreLabel(widget.item.score, widget.scoreFormat),
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
            NotesLabel(item.notes),
            _buildProgressButton(context),
          ],
        ),
      ],
    );
  }

  Widget _buildProgressButton(BuildContext context) {
    final item = widget.item;
    final text = Text(
      item.progress == item.progressMax
          ? item.progress.toString()
          : '${item.progress}/${item.progressMax ?? "?"}',
      style: Theme.of(context).textTheme.labelSmall,
    );

    if (widget.onProgressUpdated == null || item.progress == item.progressMax) {
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
          showSheet(context, EditView((id: item.mediaId, setComplete: true)));
          return;
        }

        setState(() => item.progress++);
        final err = await widget.onProgressUpdated!(item);
        if (err == null) return;

        setState(() => item.progress--);
        if (context.mounted) {
          showPopUp(
            context,
            ConfirmationDialog(
              title: 'Could not update progress',
              content: err,
            ),
          );
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
