import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:otraku/extension/card_extension.dart';
import 'package:otraku/feature/forum/forum_model.dart';
import 'package:otraku/util/routes.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/widget/cached_image.dart';
import 'package:otraku/widget/text_rail.dart';
import 'package:otraku/widget/timestamp.dart';

class ThreadItemList extends StatelessWidget {
  const ThreadItemList(this.items, this.highContrast, this.analogClock);

  final List<ThreadItem> items;
  final bool highContrast;
  final bool analogClock;

  @override
  Widget build(BuildContext context) {
    return SliverList.builder(
      itemCount: items.length,
      itemBuilder: (context, i) {
        final item = items[i];

        return Padding(
          padding: const .only(bottom: Theming.offset),
          child: Column(
            mainAxisSize: .min,
            crossAxisAlignment: .start,
            spacing: Theming.offset,
            children: [
              Row(
                spacing: Theming.offset,
                children: [
                  GestureDetector(
                    onTap: () => context.push(Routes.user(item.userId, item.userAvatar)),
                    child: ClipRRect(
                      borderRadius: Theming.borderRadiusSmall,
                      child: CachedImage(item.userAvatar, height: 50, width: 50),
                    ),
                  ),
                  Expanded(
                    child: OverflowBar(
                      spacing: 5,
                      overflowSpacing: 5,
                      children: [
                        Text(item.userName, overflow: .ellipsis, maxLines: 1),
                        Timestamp(
                          item.userTimestamp,
                          analogClock,
                          leading: Text(
                            item.isUserReplying ? 'replied' : 'posted',
                            style: TextTheme.of(context).labelSmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              CardExtension.highContrast(highContrast)(
                child: InkWell(
                  borderRadius: Theming.borderRadiusSmall,
                  onTap: () => context.push(Routes.thread(item.id)),
                  child: Padding(
                    padding: Theming.paddingAll,
                    child: Column(
                      spacing: Theming.offset,
                      mainAxisSize: .min,
                      crossAxisAlignment: .start,
                      children: [
                        Text(item.title),
                        TextRail({for (final topic in item.topics) topic: false}),
                        Row(
                          spacing: Theming.offset,
                          children: [
                            if (item.isPinned)
                              Tooltip(
                                message: 'Pinned',
                                triggerMode: .tap,
                                child: Icon(Icons.push_pin_outlined, size: Theming.iconSmall),
                              ),
                            if (item.isLocked)
                              Tooltip(
                                message: 'Locked',
                                triggerMode: .tap,
                                child: Icon(Icons.lock_outline_rounded, size: Theming.iconSmall),
                              ),
                            const Spacer(),
                            _buildInfoIcon(
                              context,
                              'Views',
                              item.viewCount.toString(),
                              Icons.remove_red_eye_outlined,
                            ),
                            _buildInfoIcon(
                              context,
                              'Replies',
                              item.replyCount.toString(),
                              Icons.reply_rounded,
                            ),
                            _buildInfoIcon(
                              context,
                              'Likes',
                              item.likeCount.toString(),
                              Icons.favorite_outline_rounded,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoIcon(BuildContext context, String label, String value, IconData icon) => Tooltip(
    message: label,
    triggerMode: .tap,
    child: Row(
      mainAxisSize: .min,
      spacing: 5,
      children: [
        Text(value, style: Theme.of(context).textTheme.labelSmall),
        Icon(icon, size: Theming.iconSmall),
      ],
    ),
  );
}
