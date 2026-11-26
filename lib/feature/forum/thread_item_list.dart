import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:otraku/extension/card_extension.dart';
import 'package:otraku/feature/forum/forum_model.dart';
import 'package:otraku/localizations/gen.dart';
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
    final l10n = AppLocalizations.of(context)!;

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
              if (item.replyCount > 0)
                Row(
                  spacing: Theming.offset,
                  children: [
                    GestureDetector(
                      onTap: () =>
                          context.push(Routes.user(item.replyUserId, item.replyUserAvatar)),
                      child: ClipRRect(
                        borderRadius: Theming.borderRadiusSmall,
                        child: CachedImage(item.replyUserAvatar, height: 50, width: 50),
                      ),
                    ),
                    Expanded(
                      child: OverflowBar(
                        spacing: 5,
                        overflowSpacing: 5,
                        children: [
                          Text(item.replyUserName, overflow: .ellipsis, maxLines: 1),
                          Timestamp(
                            item.replyCreatedAt,
                            analogClock,
                            leading: Text(
                              l10n.postsReplied,
                              style: TextTheme.of(context).labelSmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              else
                Row(
                  spacing: Theming.offset,
                  children: [
                    CardExtension.highContrast(highContrast)(
                      child: SizedBox(
                        height: 50,
                        width: 50,
                        child: Align(
                          alignment: .center,
                          child: Icon(Icons.chat_bubble_outline_rounded, size: Theming.iconSmall),
                        ),
                      ),
                    ),
                    Text(l10n.noReplies, style: TextTheme.of(context).labelSmall),
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
                          spacing: Theming.offset / 2,
                          children: [
                            GestureDetector(
                              onTap: () =>
                                  context.push(Routes.user(item.authorId, item.authorAvatar)),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(5),
                                child: CachedImage(item.authorAvatar, height: 24, width: 24),
                              ),
                            ),
                            Expanded(
                              child: OverflowBar(
                                spacing: 5,
                                overflowSpacing: 5,
                                children: [
                                  Text(item.authorName, overflow: .ellipsis, maxLines: 1),
                                  Timestamp(
                                    item.createdAt,
                                    analogClock,
                                    leading: Text(
                                      l10n.postsPosted,
                                      style: TextTheme.of(context).labelSmall,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Row(
                          spacing: Theming.offset,
                          children: [
                            if (item.isPinned)
                              Tooltip(
                                message: l10n.postsPinned,
                                triggerMode: .tap,
                                child: Icon(Icons.push_pin_outlined, size: Theming.iconSmall),
                              ),
                            if (item.isLocked)
                              Tooltip(
                                message: l10n.postsLocked,
                                triggerMode: .tap,
                                child: Icon(Icons.lock_outline_rounded, size: Theming.iconSmall),
                              ),
                            const Spacer(),
                            _buildInfoIcon(
                              context,
                              l10n.postsViews,
                              item.viewCount.toString(),
                              Icons.remove_red_eye_outlined,
                            ),
                            _buildInfoIcon(
                              context,
                              l10n.postsReplies,
                              item.replyCount.toString(),
                              Icons.reply_rounded,
                            ),
                            _buildInfoIcon(
                              context,
                              l10n.likes,
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
