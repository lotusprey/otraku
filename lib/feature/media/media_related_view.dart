import 'package:flutter/material.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/widget/cached_image.dart';
import 'package:otraku/widget/grids/sliver_grid_delegates.dart';
import 'package:otraku/widget/layouts/constrained_view.dart';
import 'package:otraku/widget/link_tile.dart';
import 'package:otraku/widget/loaders/loaders.dart';
import 'package:otraku/widget/text_rail.dart';
import 'package:otraku/feature/discover/discover_models.dart';
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
      return const SliverFillRemaining(
        child: Center(child: Text('No results')),
      );
    }

    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithMinWidthAndFixedHeight(
        minWidth: 230,
        height: 100,
      ),
      delegate: SliverChildBuilderDelegate(
        childCount: items.length,
        _buildTile,
      ),
    );
  }

  Widget _buildTile(BuildContext context, int i) {
    final details = <String, bool>{
      if (items[i].relationType != null) items[i].relationType!: true,
      if (items[i].entryStatus != null)
        items[i].entryStatus!.label(
              items[i].type == DiscoverType.anime,
            ): true,
      if (items[i].format != null) items[i].format!.label: false,
      if (items[i].releaseStatus != null) items[i].releaseStatus!: false,
    };

    return LinkTile(
      id: items[i].id,
      info: items[i].imageUrl,
      discoverType: items[i].type,
      child: Card(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Hero(
              tag: items[i].id,
              child: ClipRRect(
                borderRadius: Theming.borderRadiusSmall,
                child: Container(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: CachedImage(
                    items[i].imageUrl,
                    width: 100 / Theming.coverHtoWRatio,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: Theming.paddingAll,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: Text(
                        items[i].title,
                        overflow: TextOverflow.fade,
                      ),
                    ),
                    const SizedBox(height: 5),
                    TextRail(
                      details,
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
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
