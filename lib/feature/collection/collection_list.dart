import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/extension/date_time_extension.dart';
import 'package:otraku/feature/media/media_route_tile.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/extension/snack_bar_extension.dart';
import 'package:otraku/util/debounce.dart';
import 'package:otraku/feature/collection/collection_models.dart';
import 'package:otraku/feature/edit/edit_view.dart';
import 'package:otraku/widget/cached_image.dart';
import 'package:otraku/widget/dialogs.dart';
import 'package:otraku/widget/input/note_label.dart';
import 'package:otraku/widget/input/score_label.dart';
import 'package:otraku/widget/sheets.dart';
import 'package:otraku/widget/text_rail.dart';
import 'package:otraku/feature/media/media_models.dart';

const _tileHeight = 140.0;

class CollectionList extends StatelessWidget {
  const CollectionList({
    required this.items,
    required this.scoreFormat,
    required this.onProgressUpdated,
  });

  final List<Entry> items;
  final ScoreFormat scoreFormat;
  final Future<String?> Function(Entry, bool)? onProgressUpdated;

  @override
  Widget build(BuildContext context) {
    return SliverFixedExtentList(
      delegate: SliverChildBuilderDelegate(
        (_, i) => _Tile(items[i], scoreFormat, onProgressUpdated),
        childCount: items.length,
      ),
      // The added pixels are for the bottom margin.
      itemExtent: _tileHeight + Theming.offset,
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile(this.entry, this.scoreFormat, this.onProgressUpdated);

  final Entry entry;
  final ScoreFormat scoreFormat;
  final Future<String?> Function(Entry, bool)? onProgressUpdated;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const .only(bottom: Theming.offset),
      child: MediaRouteTile(
        key: ValueKey(entry.mediaId),
        id: entry.mediaId,
        imageUrl: entry.imageUrl,
        child: Row(
          crossAxisAlignment: .start,
          children: [
            Hero(
              tag: entry.mediaId,
              child: ClipRRect(
                borderRadius: const BorderRadius.horizontal(left: Theming.radiusSmall),
                child: Container(
                  width: _tileHeight / Theming.coverHtoWRatio,
                  color: ColorScheme.of(context).surfaceContainerHighest,
                  child: CachedImage(entry.imageUrl),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: Theming.paddingAll,
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
  final Future<String?> Function(Entry, bool)? onProgressUpdated;

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
      final key = 'Ep ${widget.item.nextEpisode} in ${widget.item.airingAt!.timeUntil}';
      textRailItems[key] = false;
    }

    if (widget.item.nextEpisode != null && widget.item.nextEpisode! - 1 > widget.item.progress) {
      final key = '${widget.item.nextEpisode! - 1 - widget.item.progress} ep behind';
      textRailItems[key] = true;
    }

    return Column(
      mainAxisAlignment: .spaceAround,
      crossAxisAlignment: .start,
      children: [
        Flexible(
          child: Column(
            mainAxisSize: .min,
            crossAxisAlignment: .stretch,
            children: [
              Flexible(child: Text(widget.item.titles[0], overflow: .fade)),
              const SizedBox(height: 5),
              TextRail(textRailItems),
            ],
          ),
        ),
        Container(
          height: 5,
          margin: const .symmetric(vertical: 3),
          decoration: BoxDecoration(
            borderRadius: Theming.borderRadiusSmall,
            gradient: LinearGradient(
              colors: [
                ColorScheme.of(context).onSurfaceVariant,
                ColorScheme.of(context).onSurfaceVariant,
                ColorScheme.of(context).surface,
                ColorScheme.of(context).surface,
              ],
              stops: [0.0, progressPercent, progressPercent, 1.0],
            ),
          ),
        ),
        Row(
          mainAxisAlignment: .spaceBetween,
          children: [
            ScoreLabel(widget.item.score, widget.scoreFormat),
            if (widget.item.repeat > 0)
              Tooltip(
                message: 'Repeats',
                child: Row(
                  mainAxisSize: .min,
                  children: [
                    const Icon(Ionicons.repeat, size: Theming.iconSmall),
                    const SizedBox(width: 3),
                    Text(widget.item.repeat.toString(), style: TextTheme.of(context).labelSmall),
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
    final foregroundColor = item.nextEpisode != null && item.progress + 1 < item.nextEpisode!
        ? ColorScheme.of(context).error
        : ColorScheme.of(context).onSurfaceVariant;

    final text = Text(
      item.progress == item.progressMax
          ? item.progress.toString()
          : '${item.progress}/${item.progressMax ?? "?"}',
      style: TextTheme.of(context).labelSmall?.copyWith(color: foregroundColor),
    );

    if (widget.onProgressUpdated == null || item.progress == item.progressMax) {
      return Tooltip(message: 'Progress', child: text);
    }

    return TextButton(
      style: TextButton.styleFrom(
        minimumSize: const Size(0, 40),
        padding: const .only(left: 5),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        foregroundColor: foregroundColor,
        iconColor: foregroundColor,
      ),
      onPressed: () {
        _debounce.cancel();

        if (item.progressMax != null && item.progress >= item.progressMax! - 1) {
          _resetProgress();

          showSheet(context, EditView((id: item.mediaId, setComplete: true)));
          return;
        }

        _lastProgress ??= item.progress;
        setState(() => item.progress++);

        _debounce.run(_update);
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

  void _update() async {
    final item = widget.item;
    var updateStatus = false;

    if (_lastProgress == 0 &&
        (item.listStatus == .planning ||
            item.listStatus == .paused ||
            item.listStatus == .dropped)) {
      await ConfirmationDialog.show(
        context,
        title: 'Update status?',
        content: 'Do you also want to update the list status?',
        primaryAction: 'Yes',
        secondaryAction: 'No',
        onConfirm: () => updateStatus = true,
      );
    }

    final err = await widget.onProgressUpdated!(item, updateStatus);
    if (err == null) {
      _lastProgress = null;
      return;
    }

    _resetProgress();
    if (mounted) {
      SnackBarExtension.show(context, 'Failed updating progress: $err');
    }
  }

  void _resetProgress() {
    if (_lastProgress == null) return;

    setState(() => widget.item.progress = _lastProgress!);
    _lastProgress = null;
  }
}
