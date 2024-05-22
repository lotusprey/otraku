import 'package:flutter/material.dart';
import 'package:otraku/common/utils/consts.dart';
import 'package:otraku/common/widgets/cached_image.dart';
import 'package:otraku/common/widgets/entry_labels.dart';
import 'package:otraku/common/widgets/grids/sliver_grid_delegates.dart';
import 'package:otraku/common/widgets/link_tile.dart';
import 'package:otraku/common/widgets/paged_view.dart';
import 'package:otraku/modules/discover/discover_models.dart';
import 'package:otraku/modules/media/media_models.dart';
import 'package:otraku/modules/media/media_provider.dart';

class MediaFollowingSubview extends StatelessWidget {
  const MediaFollowingSubview({required this.id, required this.scrollCtrl});

  final int id;
  final ScrollController scrollCtrl;

  @override
  Widget build(BuildContext context) {
    return PagedView<MediaFollowing>(
      withTopOffset: false,
      scrollCtrl: scrollCtrl,
      onRefresh: (invalidate) => invalidate(mediaFollowingProvider(id)),
      provider: mediaFollowingProvider(id),
      onData: (data) => _MediaFollowingGrid(data.items),
    );
  }
}

class _MediaFollowingGrid extends StatelessWidget {
  const _MediaFollowingGrid(this.items);

  final List<MediaFollowing> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SliverFillRemaining(
        child: Center(child: Text('No results')),
      );
    }

    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithMinWidthAndFixedHeight(
        minWidth: 300,
        height: 70,
      ),
      delegate: SliverChildBuilderDelegate(
        childCount: items.length,
        (context, i) => LinkTile(
          id: items[i].userId,
          info: items[i].userAvatar,
          discoverType: DiscoverType.user,
          child: Card(
            child: Row(
              children: [
                Hero(
                  tag: items[i].userId,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.horizontal(
                      left: Consts.radiusMin,
                    ),
                    child: CachedImage(items[i].userAvatar, width: 70),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 10,
                      left: 10,
                      right: 10,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(items[i].userName),
                        SizedBox(
                          height: 35,
                          child: Row(
                            children: [
                              Expanded(child: Text(items[i].status)),
                              Expanded(
                                child: Center(
                                  child: NotesLabel(items[i].notes),
                                ),
                              ),
                              Expanded(
                                child: Center(
                                  child: ScoreLabel(
                                    items[i].score,
                                    items[i].scoreFormat,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
