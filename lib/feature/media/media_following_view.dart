import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:otraku/util/routes.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/widget/cached_image.dart';
import 'package:otraku/widget/input/note_label.dart';
import 'package:otraku/widget/input/score_label.dart';
import 'package:otraku/widget/grid/sliver_grid_delegates.dart';
import 'package:otraku/widget/paged_view.dart';
import 'package:otraku/feature/media/media_models.dart';
import 'package:otraku/feature/media/media_provider.dart';

class MediaFollowingSubview extends StatelessWidget {
  const MediaFollowingSubview({required this.id, required this.scrollCtrl});

  final int id;
  final ScrollController scrollCtrl;

  @override
  Widget build(BuildContext context) {
    return PagedView(
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
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithMinWidthAndFixedHeight(
        minWidth: 300,
        height: 70,
      ),
      delegate: SliverChildBuilderDelegate(
        childCount: items.length,
        (context, i) => GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => context.push(
            Routes.user(items[i].userId, items[i].userAvatar),
          ),
          child: Card(
            child: Row(
              children: [
                Hero(
                  tag: items[i].userId,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.horizontal(
                      left: Theming.radiusSmall,
                    ),
                    child: CachedImage(items[i].userAvatar, width: 70),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: Theming.offset,
                      left: Theming.offset,
                      right: Theming.offset,
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
                              Expanded(
                                child: Text(items[i].entryStatus.label(null)),
                              ),
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
