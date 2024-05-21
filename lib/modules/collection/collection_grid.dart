import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/modules/collection/collection_models.dart';
import 'package:otraku/modules/discover/discover_models.dart';
import 'package:otraku/modules/edit/edit_view.dart';
import 'package:otraku/common/utils/consts.dart';
import 'package:otraku/common/widgets/cached_image.dart';
import 'package:otraku/common/widgets/grids/sliver_grid_delegates.dart';
import 'package:otraku/common/widgets/link_tile.dart';
import 'package:otraku/common/widgets/overlays/dialogs.dart';
import 'package:otraku/common/widgets/overlays/sheets.dart';

class CollectionGrid extends StatelessWidget {
  const CollectionGrid({required this.items, required this.onProgressUpdated});

  final List<Entry> items;
  final Future<String?> Function(Entry)? onProgressUpdated;

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
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
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
                _IncrementButton(items[i], onProgressUpdated),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IncrementButton extends StatefulWidget {
  const _IncrementButton(this.item, this.onProgressUpdated);

  final Entry item;
  final Future<String?> Function(Entry)? onProgressUpdated;

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

    final overridenTextColor =
        item.nextEpisode != null && item.progress + 1 < item.nextEpisode!
            ? Theme.of(context).colorScheme.error
            : null;

    if (widget.onProgressUpdated == null) {
      return Tooltip(
        message: 'Progress',
        child: SizedBox(
          height: 30,
          child: Center(
            child: Text(
              '${item.progress}/${item.progressMax ?? "?"}',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: overridenTextColor,
                  ),
            ),
          ),
        ),
      );
    }

    return TextButton(
      style: TextButton.styleFrom(
        minimumSize: const Size(0, 30),
        padding: const EdgeInsets.symmetric(horizontal: 5),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        foregroundColor: overridenTextColor,
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
