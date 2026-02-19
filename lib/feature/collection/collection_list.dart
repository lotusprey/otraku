import 'dart:math';

import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/extension/build_context_extension.dart';
import 'package:otraku/extension/card_extension.dart';
import 'package:otraku/extension/date_time_extension.dart';
import 'package:otraku/feature/media/media_route_tile.dart';
import 'package:otraku/localizations/gen.dart';
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

class CollectionList extends StatelessWidget {
  const CollectionList({
    required this.items,
    required this.scoreFormat,
    required this.onProgressUpdated,
    required this.highContrast,
  });

  final List<Entry> items;
  final ScoreFormat scoreFormat;
  final Future<String?> Function(Entry, bool)? onProgressUpdated;
  final bool highContrast;

  @override
  Widget build(BuildContext context) {
    final textTheme = TextTheme.of(context);
    final bodyMediumLineHeight = context.lineHeight(textTheme.bodyMedium!);
    final labelMediumLineHeight = context.lineHeight(textTheme.labelMedium!);
    final tileHeight = bodyMediumLineHeight * 2 + labelMediumLineHeight * 2 + Theming.offset + 69;

    return SliverFixedExtentList(
      delegate: SliverChildBuilderDelegate(
        (_, i) => _Tile(
          items[i],
          scoreFormat,
          onProgressUpdated,
          highContrast,
          tileHeight / Theming.coverHtoWRatio,
        ),
        childCount: items.length,
      ),
      // The added pixels are for the bottom margin.
      itemExtent: tileHeight,
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile(
    this.entry,
    this.scoreFormat,
    this.onProgressUpdated,
    this.highContrast,
    this.coverWidth,
  );

  final Entry entry;
  final ScoreFormat scoreFormat;
  final Future<String?> Function(Entry, bool)? onProgressUpdated;
  final bool highContrast;
  final double coverWidth;

  @override
  Widget build(BuildContext context) {
    return CardExtension.highContrast(highContrast)(
      margin: const .only(bottom: Theming.offset),
      child: MediaRouteTile(
        key: ValueKey(entry.mediaId),
        id: entry.mediaId,
        imageUrl: entry.imageUrl,
        child: Row(
          crossAxisAlignment: .start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Theming.radiusSmall),
              child: DecoratedBox(
                decoration: BoxDecoration(color: ColorScheme.of(context).surfaceContainerHighest),
                child: CachedImage(entry.imageUrl, width: coverWidth),
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
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = ColorScheme.of(context);
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
    if (item.format != null) {
      textRailItems[item.format!.localize(l10n)] = false;
    }

    if (item.nextEpisode != null && item.airingAt != null) {
      final key = l10n.mediaEpisodeIn(item.nextEpisode!, item.airingAt!.timeUntil);
      textRailItems[key] = false;
    }

    if (item.nextEpisode != null && item.nextEpisode! - 1 > item.progress) {
      final key = l10n.mediaEpisodesBehind(item.nextEpisode! - item.progress - 1);
      textRailItems[key] = true;
    }

    return Column(
      mainAxisAlignment: .spaceAround,
      crossAxisAlignment: .stretch,
      children: [
        Flexible(child: Text(widget.item.titles[0], overflow: .ellipsis, maxLines: 2)),
        TextRail(textRailItems, maxLines: 2),
        Padding(
          padding: const .symmetric(vertical: 3),
          child: SizedBox(
            height: 3,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: Theming.borderRadiusSmall,
                gradient: LinearGradient(
                  colors: [
                    colorScheme.onSurfaceVariant,
                    colorScheme.onSurfaceVariant,
                    colorScheme.surfaceContainerHighest,
                    colorScheme.surfaceContainerHighest,
                  ],
                  stops: [0.0, progressPercent, progressPercent, 1.0],
                ),
              ),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: .spaceBetween,
          children: [
            ScoreLabel(item.score, widget.scoreFormat),
            if (item.repeat > 0)
              Tooltip(
                message: l10n.entryRepeats,
                child: Row(
                  mainAxisSize: .min,
                  spacing: 3,
                  children: [
                    const Icon(Ionicons.repeat, size: Theming.iconSmall),
                    Text(item.repeat.toString(), style: TextTheme.of(context).labelSmall),
                  ],
                ),
              )
            else
              const SizedBox(),
            NotesLabel(item.notes),
            _buildProgressButton(context, l10n),
          ],
        ),
      ],
    );
  }

  Widget _buildProgressButton(BuildContext context, AppLocalizations l10n) {
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
      return Tooltip(message: l10n.entryProgress, child: text);
    }

    return TextButton(
      style: TextButton.styleFrom(
        minimumSize: const Size(0, 40),
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

        _debounce.run(() => _update(l10n));
      },
      child: Tooltip(
        message: l10n.entryProgressIncrement,
        child: Row(
          spacing: 3,
          children: [
            text,
            const Icon(Ionicons.add_outline, size: Theming.iconSmall),
          ],
        ),
      ),
    );
  }

  void _update(AppLocalizations l10n) async {
    final item = widget.item;
    var updateStatus = false;

    if (_lastProgress == 0 &&
        (item.listStatus == .planning ||
            item.listStatus == .paused ||
            item.listStatus == .dropped)) {
      await ConfirmationDialog.show(
        context,
        title: l10n.entryProgressUpdateStatusQuestion,
        primaryAction: l10n.actionYes,
        secondaryAction: l10n.actionNo,
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
      SnackBarExtension.show(context, l10n.errorFailedUpdatingProgress(err.toString()));
    }
  }

  void _resetProgress() {
    if (_lastProgress == null) return;

    setState(() => widget.item.progress = _lastProgress!);
    _lastProgress = null;
  }
}
