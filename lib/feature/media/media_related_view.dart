import 'package:flutter/material.dart';
import 'package:otraku/extension/build_context_extension.dart';
import 'package:otraku/extension/card_extension.dart';
import 'package:otraku/feature/media/media_route_tile.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/widget/cached_image.dart';
import 'package:otraku/widget/grid/sliver_grid_delegates.dart';
import 'package:otraku/widget/layout/constrained_view.dart';
import 'package:otraku/widget/loaders.dart';
import 'package:otraku/widget/text_rail.dart';
import 'package:otraku/feature/media/media_models.dart';

class MediaRelatedSubview extends StatelessWidget {
  const MediaRelatedSubview({
    required this.relations,
    required this.scrollCtrl,
    required this.invalidate,
    required this.highContrast,
  });

  final List<RelatedMedia> relations;
  final ScrollController scrollCtrl;
  final void Function() invalidate;
  final bool highContrast;

  @override
  Widget build(BuildContext context) {
    return ConstrainedView(
      child: CustomScrollView(
        controller: scrollCtrl,
        physics: Theming.bouncyPhysics,
        slivers: [
          SliverRefreshControl(onRefresh: invalidate),
          _MediaRelatedGrid(relations, highContrast),
          const SliverFooter(),
        ],
      ),
    );
  }
}

class _MediaRelatedGrid extends StatelessWidget {
  const _MediaRelatedGrid(this.items, this.highContrast);

  final List<RelatedMedia> items;
  final bool highContrast;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SliverFillRemaining(child: Center(child: Text('No results')));
    }

    final textTheme = TextTheme.of(context);
    final bodyMediumLineHeight = context.lineHeight(textTheme.bodyMedium!);
    final labelMediumLineHeight = context.lineHeight(textTheme.labelMedium!);
    final tileHeight = bodyMediumLineHeight * 2 + labelMediumLineHeight * 2 + 25;
    final coverWidth = tileHeight / Theming.coverHtoWRatio;

    return SliverGrid(
      gridDelegate: SliverGridDelegateWithMinWidthAndFixedHeight(minWidth: 270, height: tileHeight),
      delegate: SliverChildBuilderDelegate(childCount: items.length, (context, i) {
        final textRailItems = <String, bool>{
          if (items[i].relationType != null) items[i].relationType!: true,
          if (items[i].entryStatus != null) items[i].entryStatus!.label(items[i].isAnime): true,
          if (items[i].format != null) items[i].format!.label: false,
          if (items[i].releaseStatus != null) items[i].releaseStatus!: false,
        };

        return CardExtension.highContrast(highContrast)(
          child: MediaRouteTile(
            id: items[i].id,
            imageUrl: items[i].imageUrl,
            child: Row(
              mainAxisAlignment: .start,
              children: [
                Hero(
                  tag: items[i].id,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.horizontal(left: Theming.radiusSmall),
                    child: Container(
                      color: ColorScheme.of(context).surfaceContainerHighest,
                      child: CachedImage(items[i].imageUrl, width: coverWidth),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: Theming.paddingAll,
                    child: Column(
                      mainAxisAlignment: .spaceEvenly,
                      crossAxisAlignment: .start,
                      spacing: 5,
                      children: [
                        Flexible(child: Text(items[i].title, overflow: .ellipsis, maxLines: 2)),
                        TextRail(
                          textRailItems,
                          style: TextTheme.of(context).labelMedium,
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
