import 'package:flutter/material.dart';
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
  });

  final List<RelatedMedia> relations;
  final ScrollController scrollCtrl;
  final void Function() invalidate;

  @override
  Widget build(BuildContext context) {
    return ConstrainedView(
      child: CustomScrollView(
        controller: scrollCtrl,
        physics: Theming.bouncyPhysics,
        slivers: [
          SliverRefreshControl(onRefresh: invalidate),
          _MediaRelatedGrid(relations),
          const SliverFooter(),
        ],
      ),
    );
  }
}

class _MediaRelatedGrid extends StatelessWidget {
  const _MediaRelatedGrid(this.items);

  final List<RelatedMedia> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SliverFillRemaining(child: Center(child: Text('No results')));
    }

    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithMinWidthAndFixedHeight(minWidth: 270, height: 100),
      delegate: SliverChildBuilderDelegate(childCount: items.length, _buildTile),
    );
  }

  Widget _buildTile(BuildContext context, int i) {
    final textRailItems = <String, bool>{
      if (items[i].relationType != null) items[i].relationType!: true,
      if (items[i].entryStatus != null) items[i].entryStatus!.label(items[i].isAnime): true,
      if (items[i].format != null) items[i].format!.label: false,
      if (items[i].releaseStatus != null) items[i].releaseStatus!: false,
    };

    return Card(
      child: MediaRouteTile(
        id: items[i].id,
        imageUrl: items[i].imageUrl,
        child: Row(
          mainAxisAlignment: .start,
          children: [
            Hero(
              tag: items[i].id,
              child: ClipRRect(
                borderRadius: Theming.borderRadiusSmall,
                child: Container(
                  color: ColorScheme.of(context).surfaceContainerHighest,
                  child: CachedImage(items[i].imageUrl, width: 100 / Theming.coverHtoWRatio),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: Theming.paddingAll,
                child: Column(
                  mainAxisAlignment: .spaceEvenly,
                  crossAxisAlignment: .start,
                  children: [
                    Flexible(child: Text(items[i].title, overflow: .fade)),
                    const SizedBox(height: 5),
                    TextRail(textRailItems, style: TextTheme.of(context).labelMedium),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
