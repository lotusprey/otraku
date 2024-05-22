import 'package:flutter/material.dart';
import 'package:otraku/common/utils/consts.dart';
import 'package:otraku/common/widgets/cached_image.dart';
import 'package:otraku/common/widgets/grids/sliver_grid_delegates.dart';
import 'package:otraku/common/widgets/layouts/constrained_view.dart';
import 'package:otraku/common/widgets/link_tile.dart';
import 'package:otraku/common/widgets/loaders/loaders.dart';
import 'package:otraku/common/widgets/text_rail.dart';
import 'package:otraku/modules/discover/discover_models.dart';
import 'package:otraku/modules/media/media_models.dart';

class MediaRelatedSubview extends StatelessWidget {
  const MediaRelatedSubview({
    required this.relations,
    required this.scrollCtrl,
  });

  final List<RelatedMedia> relations;
  final ScrollController scrollCtrl;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: scrollCtrl,
      slivers: [
        const SliverToBoxAdapter(child: SizedBox(height: 10)),
        _MediaRelatedGrid(relations),
        const SliverFooter(),
      ],
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

    return ConstrainedView(
      child: SliverGrid(
        gridDelegate: const SliverGridDelegateWithMinWidthAndFixedHeight(
          minWidth: 230,
          height: 100,
        ),
        delegate: SliverChildBuilderDelegate(
          childCount: items.length,
          _buildTile,
        ),
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
      if (items[i].format != null) items[i].format!: false,
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
                borderRadius: Consts.borderRadiusMin,
                child: Container(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: CachedImage(
                    items[i].imageUrl,
                    width: 100 / Consts.coverHtoWRatio,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: Consts.padding,
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
