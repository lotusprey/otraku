import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/collection/entry_item.dart';
import 'package:otraku/constants/consts.dart';
import 'package:otraku/discover/discover_models.dart';
import 'package:otraku/edit/edit_view.dart';
import 'package:otraku/widgets/link_tile.dart';
import 'package:otraku/widgets/fade_image.dart';
import 'package:otraku/widgets/grids/sliver_grid_delegates.dart';
import 'package:otraku/widgets/overlays/sheets.dart';

class MinimalCollectionGrid extends StatelessWidget {
  MinimalCollectionGrid({required this.items, required this.updateProgress});

  final List<EntryItem> items;
  final void Function(EntryItem) updateProgress;

  @override
  Widget build(BuildContext context) {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithMinWidthAndExtraHeight(
        minWidth: 100,
        extraHeight: 70,
        rawHWRatio: Consts.coverHtoWRatio,
      ),
      delegate: SliverChildBuilderDelegate(
        (_, i) => DecoratedBox(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: Consts.borderRadiusMin,
          ),
          child: LinkTile(
            id: items[i].mediaId,
            discoverType: DiscoverType.anime,
            text: items[i].imageUrl,
            child: Column(
              children: [
                Expanded(
                  child: Hero(
                    tag: items[i].mediaId,
                    child: ClipRRect(
                      borderRadius: Consts.borderRadiusMin,
                      child: Container(
                        color: Theme.of(context).colorScheme.surface,
                        child: FadeImage(items[i].imageUrl),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 5, right: 5, top: 5),
                  child: SizedBox(
                    height: 35,
                    child: Text(
                      items[i].title,
                      overflow: TextOverflow.fade,
                      maxLines: 2,
                      style: Theme.of(context).textTheme.bodyText2,
                    ),
                  ),
                ),
                _IncrementButton(items[i], updateProgress),
              ],
            ),
          ),
        ),
        childCount: items.length,
      ),
    );
  }
}

class _IncrementButton extends StatefulWidget {
  _IncrementButton(this.item, this.updateProgress);

  final EntryItem item;
  final void Function(EntryItem) updateProgress;

  @override
  State<_IncrementButton> createState() => _IncrementButtonState();
}

class _IncrementButtonState extends State<_IncrementButton> {
  @override
  Widget build(BuildContext context) {
    final model = widget.item;

    if (model.progress == model.progressMax)
      return Tooltip(
        message: 'Progress',
        child: SizedBox(
          height: 30,
          child: Center(
            child: Text(
              model.progress.toString(),
              style: Theme.of(context).textTheme.subtitle2,
            ),
          ),
        ),
      );

    final warning =
        model.nextEpisode != null && model.progress + 1 < model.nextEpisode!;

    return TextButton(
      style: TextButton.styleFrom(
        minimumSize: const Size(0, 30),
        padding: EdgeInsets.symmetric(horizontal: 5),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        primary: warning ? Theme.of(context).colorScheme.error : null,
      ),
      onPressed: () {
        if (model.progressMax == null ||
            model.progress < model.progressMax! - 1) {
          setState(() => model.progress++);
          widget.updateProgress(model);
        } else
          showSheet(context, EditView(model.mediaId, complete: true));
      },
      child: Tooltip(
        message: 'Increment Progress',
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${model.progress}/${model.progressMax ?? "?"}',
              style: TextStyle(fontSize: Consts.fontSmall),
            ),
            const SizedBox(width: 3),
            const Icon(Ionicons.add_outline, size: Consts.iconSmall),
          ],
        ),
      ),
    );
  }
}
