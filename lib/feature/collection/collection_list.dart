import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/extension/date_time_extension.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/extension/snack_bar_extension.dart';
import 'package:otraku/widget/debounce.dart';
import 'package:otraku/widget/entry_labels.dart';
import 'package:otraku/feature/collection/collection_models.dart';
import 'package:otraku/feature/discover/discover_models.dart';
import 'package:otraku/feature/edit/edit_view.dart';
import 'package:otraku/widget/cached_image.dart';
import 'package:otraku/widget/link_tile.dart';
import 'package:otraku/widget/overlays/sheets.dart';
import 'package:otraku/widget/text_rail.dart';
import 'package:otraku/feature/media/media_models.dart';

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
      itemExtent: _TILE_HEIGHT + Theming.offset,
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
      margin: const EdgeInsets.only(bottom: Theming.offset),
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
                borderRadius: const BorderRadius.horizontal(
                  left: Theming.radiusSmall,
                ),
                child: Container(
                  width: _TILE_HEIGHT / Theming.coverHtoWRatio,
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: CachedImage(entry.imageUrl),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(
                  top: Theming.offset,
                  left: Theming.offset,
                  right: Theming.offset,
                ),
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
  final _debounce = Debounce();
  int? _lastProgress;

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
      textRailItems[widget.item.format!.label] = false;
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
            borderRadius: Theming.borderRadiusSmall,
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.onSurfaceVariant,
                Theme.of(context).colorScheme.onSurfaceVariant,
                Theme.of(context).colorScheme.surface,
                Theme.of(context).colorScheme.surface,
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
                    const Icon(Ionicons.repeat, size: Theming.iconSmall),
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
      onPressed: () {
        if (item.progressMax != null &&
            item.progress >= item.progressMax! - 1) {
          _debounce.cancel();
          _resetProgress();

          showSheet(context, EditView((id: item.mediaId, setComplete: true)));
          return;
        }

        _debounce.cancel();
        _lastProgress ??= item.progress;
        setState(() => item.progress++);

        _debounce.run(() async {
          final err = await widget.onProgressUpdated!(item);
          if (err == null) {
            _lastProgress = null;
            return;
          }

          _resetProgress();
          if (context.mounted) {
            SnackBarExtension.show(context, 'Failed updating progress: $err');
          }
        });
      },
      child: Tooltip(
        message: 'Increment Progress',
        child: Row(
          children: [
            text,
            const SizedBox(width: 3),
            const Icon(Ionicons.add_outline, size: Theming.iconSmall),
          ],
        ),
      ),
    );
  }

  void _resetProgress() {
    if (_lastProgress == null) return;

    setState(() => widget.item.progress = _lastProgress!);
    _lastProgress = null;
  }
}
