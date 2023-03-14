import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/collection/collection_models.dart';
import 'package:otraku/discover/discover_models.dart';
import 'package:otraku/edit/edit_providers.dart';
import 'package:otraku/edit/edit_view.dart';
import 'package:otraku/media/media_constants.dart';
import 'package:otraku/utils/consts.dart';
import 'package:otraku/widgets/cached_image.dart';
import 'package:otraku/widgets/grids/sliver_grid_delegates.dart';
import 'package:otraku/widgets/link_tile.dart';
import 'package:otraku/widgets/overlays/dialogs.dart';
import 'package:otraku/widgets/overlays/sheets.dart';

class CollectionGrid extends StatelessWidget {
  const CollectionGrid({
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
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithMinWidthAndExtraHeight(
        minWidth: 100,
        extraHeight: 70,
        rawHWRatio: Consts.coverHtoWRatio,
      ),
      delegate: SliverChildBuilderDelegate(
        childCount: items.length,
        (context, i) => Card(
          child: LinkTile(
            id: items[i].mediaId,
            discoverType: DiscoverType.anime,
            info: items[i].imageUrl,
            child: Column(
              children: [
                Expanded(
                  child: Hero(
                    tag: items[i].mediaId,
                    child: ClipRRect(
                      borderRadius: Consts.borderRadiusMin,
                      child: Container(
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        child: CachedImage(items[i].imageUrl),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 5, right: 5, top: 5),
                  child: SizedBox(
                    height: 35,
                    child: Text(
                      items[i].titles[0],
                      overflow: TextOverflow.fade,
                      maxLines: 2,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ),
                _IncrementButton(items[i], onProgressUpdate),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IncrementButton extends StatefulWidget {
  const _IncrementButton(this.item, this.onProgressUpdate);

  final Entry item;
  final void Function(Entry, List<String>)? onProgressUpdate;

  @override
  State<_IncrementButton> createState() => _IncrementButtonState();
}

class _IncrementButtonState extends State<_IncrementButton> {
  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    if (item.progress == item.progressMax) {
      return Tooltip(
        message: 'Progress',
        child: SizedBox(
          height: 30,
          child: Center(
            child: Text(
              item.progress.toString(),
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
        ),
      );
    }

    final warning =
        item.nextEpisode != null && item.progress + 1 < item.nextEpisode!;

    return TextButton(
      style: TextButton.styleFrom(
        minimumSize: const Size(0, 30),
        padding: const EdgeInsets.symmetric(horizontal: 5),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        foregroundColor: warning ? Theme.of(context).colorScheme.error : null,
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${item.progress}/${item.progressMax ?? "?"}',
              style: const TextStyle(fontSize: Consts.fontSmall),
            ),
            const SizedBox(width: 3),
            const Icon(Ionicons.add_outline, size: Consts.iconSmall),
          ],
        ),
      ),
    );
  }
}
