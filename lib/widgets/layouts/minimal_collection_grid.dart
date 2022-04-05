import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/constants/consts.dart';
import 'package:otraku/constants/explorable.dart';
import 'package:otraku/models/list_entry_model.dart';
import 'package:otraku/views/edit_view.dart';
import 'package:otraku/widgets/explore_indexer.dart';
import 'package:otraku/widgets/fade_image.dart';
import 'package:otraku/widgets/layouts/sliver_grid_delegates.dart';
import 'package:otraku/widgets/overlays/sheets.dart';

class MinimalCollectionGrid extends StatelessWidget {
  MinimalCollectionGrid({required this.items, required this.updateProgress});

  final List<ListEntryModel> items;
  final void Function(ListEntryModel) updateProgress;

  @override
  Widget build(BuildContext context) {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithMinWidthAndExtraHeight(
        minWidth: 100,
        extraHeight: 70,
        rawHWRatio: Consts.COVER_HW_RATIO,
      ),
      delegate: SliverChildBuilderDelegate(
        (_, i) => DecoratedBox(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: Consts.BORDER_RAD_MIN,
          ),
          child: ExploreIndexer(
            id: items[i].mediaId,
            explorable: Explorable.anime,
            imageUrl: items[i].cover,
            child: Column(
              children: [
                Expanded(
                  child: Hero(
                    tag: items[i].mediaId,
                    child: ClipRRect(
                      borderRadius: Consts.BORDER_RAD_MIN,
                      child: Container(
                        color: Theme.of(context).colorScheme.surface,
                        child: FadeImage(items[i].cover),
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
  _IncrementButton(this.model, this.updateProgress);

  final ListEntryModel model;
  final void Function(ListEntryModel) updateProgress;

  @override
  State<_IncrementButton> createState() => _IncrementButtonState();
}

class _IncrementButtonState extends State<_IncrementButton> {
  @override
  Widget build(BuildContext context) {
    final model = widget.model;
    final text = Text(
      model.progress == model.progressMax
          ? model.progress.toString()
          : '${model.progress}/${model.progressMax ?? "?"}',
      style: Theme.of(context).textTheme.subtitle2,
    );

    if (model.progress == model.progressMax)
      return Tooltip(
        message: 'Progress',
        child: SizedBox(height: 30, child: Center(child: text)),
      );

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
          widget.updateProgress(model);
        } else
          showSheet(context, EditView(model.mediaId, complete: true));
      },
      child: Tooltip(
        message: 'Increment Progress',
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
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
