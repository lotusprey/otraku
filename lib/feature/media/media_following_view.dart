import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/extension/build_context_extension.dart';
import 'package:otraku/extension/card_extension.dart';
import 'package:otraku/util/routes.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/widget/cached_image.dart';
import 'package:otraku/widget/input/note_label.dart';
import 'package:otraku/widget/input/score_label.dart';
import 'package:otraku/widget/grid/sliver_grid_delegates.dart';
import 'package:otraku/widget/paged_view.dart';
import 'package:otraku/feature/media/media_models.dart';
import 'package:otraku/feature/media/media_provider.dart';
import 'package:otraku/widget/text_rail.dart';

class MediaFollowingSubview extends StatelessWidget {
  const MediaFollowingSubview({
    required this.id,
    required this.scrollCtrl,
    required this.highContrast,
  });

  final int id;
  final ScrollController scrollCtrl;
  final bool highContrast;

  @override
  Widget build(BuildContext context) {
    return PagedView(
      scrollCtrl: scrollCtrl,
      onRefresh: (invalidate) => invalidate(mediaFollowingProvider(id)),
      provider: mediaFollowingProvider(id),
      onData: (data) => _MediaFollowingGrid(data.items, highContrast),
    );
  }
}

class _MediaFollowingGrid extends StatelessWidget {
  const _MediaFollowingGrid(this.items, this.highContrast);

  final List<MediaFollowing> items;
  final bool highContrast;

  @override
  Widget build(BuildContext context) {
    final bodyMediumLineHeight = context.lineHeight(TextTheme.of(context).bodyMedium!);
    final tileHeight = bodyMediumLineHeight + max(bodyMediumLineHeight, 35) + 5;

    return SliverGrid(
      gridDelegate: SliverGridDelegateWithMinWidthAndFixedHeight(minWidth: 300, height: tileHeight),
      delegate: SliverChildBuilderDelegate(
        childCount: items.length,
        (context, i) => GestureDetector(
          behavior: .opaque,
          onTap: () => context.push(Routes.user(items[i].userId, items[i].userAvatar)),
          child: CardExtension.highContrast(highContrast)(
            child: Row(
              children: [
                Hero(
                  tag: items[i].userId,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.horizontal(left: Theming.radiusSmall),
                    //Profile Picture
                    child: CachedImage(items[i].userAvatar, width: tileHeight),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const .only(top: 5, left: Theming.offset, right: Theming.offset),
                    child: Column(
                      mainAxisAlignment: .spaceBetween,
                      crossAxisAlignment: .start,
                      children: [
                        Row(
                          mainAxisAlignment: .spaceBetween,
                          children: [
                            //Name
                            Text(items[i].userName, overflow: .ellipsis, maxLines: 1),
                            //Score
                            ScoreLabel(items[i].score, items[i].scoreFormat),
                          ],
                        ),
                        //Progress
                        SizedBox(
                          height: 35,
                          child: Row(
                            mainAxisAlignment: .spaceBetween,
                            children: [
                              TextRail({
                                items[i].entryStatus.label(null): true,
                                items[i].progress == items[i].progressMax
                                        ? items[i].progress.toString()
                                        : '${items[i].progress}/${items[i].progressMax ?? "?"}':
                                    false,
                              }),
                              const Spacer(),
                              //Repeat
                              if (items[i].repeat > 0)
                                ConstrainedBox(
                                  constraints: BoxConstraints(minWidth: Theming.minTapTarget),
                                  child: Align(
                                    alignment: .centerRight,
                                    child: Tooltip(
                                      message: 'Repeats',
                                      child: Row(
                                        mainAxisSize: .min,
                                        spacing: 3,
                                        children: [
                                          const Icon(Ionicons.repeat, size: Theming.iconSmall),
                                          Text(
                                            items[i].repeat.toString(),
                                            style: TextTheme.of(context).labelSmall,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              //Notes
                              if (items[i].notes != '')
                                ConstrainedBox(
                                  constraints: BoxConstraints(minWidth: Theming.minTapTarget),
                                  child: Align(
                                    alignment: .centerRight,
                                    child: NotesLabel(items[i].notes),
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
