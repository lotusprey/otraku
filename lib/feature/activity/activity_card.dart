import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/extension/snack_bar_extension.dart';
import 'package:otraku/feature/activity/activity_model.dart';
import 'package:otraku/feature/composition/composition_model.dart';
import 'package:otraku/feature/composition/composition_view.dart';
import 'package:otraku/feature/media/media_route_tile.dart';
import 'package:otraku/util/routes.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/widget/cached_image.dart';
import 'package:otraku/widget/html_content.dart';
import 'package:otraku/widget/dialogs.dart';
import 'package:otraku/widget/sheets.dart';
import 'package:otraku/widget/timestamp.dart';

class ActivityCard extends StatelessWidget {
  const ActivityCard({
    required this.activity,
    required this.footer,
    required this.withHeader,
    required this.analogClock,
  });

  final Activity activity;
  final ActivityFooter footer;
  final bool withHeader;
  final bool analogClock;

  @override
  Widget build(BuildContext context) {
    final body = Card(
      margin: const EdgeInsets.only(bottom: Theming.offset),
      child: Padding(
        padding: const EdgeInsets.only(
          top: Theming.offset,
          left: Theming.offset,
          right: Theming.offset,
        ),
        child: Column(
          children: [
            if (activity is MediaActivity)
              _ActivityMediaBox(activity as MediaActivity)
            else
              HtmlContent(activity.text),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(child: Timestamp(activity.createdAt, analogClock)),
                footer,
              ],
            ),
          ],
        ),
      ),
    );

    if (!withHeader) return body;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => context.push(
                  Routes.user(activity.authorId, activity.authorAvatarUrl),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipRRect(
                      borderRadius: Theming.borderRadiusSmall,
                      child: CachedImage(
                        activity.authorAvatarUrl,
                        height: 50,
                        width: 50,
                      ),
                    ),
                    const SizedBox(width: Theming.offset),
                    Flexible(
                      child: Text(
                        activity.authorName,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ...switch (activity) {
              MessageActivity message => [
                  if (message.isPrivate)
                    const Padding(
                      padding: EdgeInsets.only(left: Theming.offset),
                      child: Icon(Ionicons.eye_off_outline),
                    ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: Theming.offset),
                    child: Icon(Icons.arrow_right_alt),
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => context.push(
                      Routes.user(
                        message.recipientId,
                        message.recipientAvatarUrl,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: Theming.borderRadiusSmall,
                      child: CachedImage(
                        message.recipientAvatarUrl,
                        height: 50,
                        width: 50,
                      ),
                    ),
                  ),
                ],
              _ when activity.isPinned => const [
                  Padding(
                    padding: EdgeInsets.only(left: Theming.offset),
                    child: Icon(Icons.push_pin_outlined),
                  ),
                ],
              _ => const [],
            },
          ],
        ),
        const SizedBox(height: 5),
        body,
      ],
    );
  }
}

class _ActivityMediaBox extends StatelessWidget {
  const _ActivityMediaBox(this.item);

  final MediaActivity item;

  @override
  Widget build(BuildContext context) {
    return MediaRouteTile(
      id: item.mediaId,
      imageUrl: item.coverUrl,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 108),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: Theming.borderRadiusSmall,
              child: CachedImage(item.coverUrl, width: 70),
            ),
            Expanded(
              child: Padding(
                padding: Theming.paddingAll,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: Text.rich(
                        overflow: TextOverflow.fade,
                        TextSpan(
                          children: [
                            TextSpan(
                              text: item.text,
                              style: TextTheme.of(context).labelMedium,
                            ),
                            TextSpan(
                              text: item.title,
                              style: TextTheme.of(context).bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (item.format != null) ...[
                      const SizedBox(height: 5),
                      Text(
                        item.format!,
                        style: TextTheme.of(context).labelMedium,
                      ),
                    ],
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

class ActivityFooter extends StatefulWidget {
  const ActivityFooter({
    required this.viewerId,
    required this.activity,
    required this.remove,
    required this.togglePin,
    required this.toggleLike,
    required this.toggleSubscription,
    required this.reply,
    required this.onEdited,
  });

  final int? viewerId;
  final Activity activity;
  final Future<Object?> Function() remove;
  final Future<Object?> Function() toggleLike;
  final Future<Object?> Function() toggleSubscription;
  final Future<Object?> Function() togglePin;
  final Future<Object?> Function()? reply;
  final void Function(Map<String, dynamic>)? onEdited;

  @override
  State<ActivityFooter> createState() => _ActivityFooterState();
}

class _ActivityFooterState extends State<ActivityFooter> {
  @override
  Widget build(BuildContext context) {
    final activity = widget.activity;

    return Row(
      children: [
        SizedBox(
          height: 40,
          child: Tooltip(
            message: 'More',
            child: InkResponse(
              radius: Theming.radiusSmall.x,
              onTap: _showMoreSheet,
              child: const Icon(
                Ionicons.ellipsis_horizontal,
                size: Theming.iconSmall,
              ),
            ),
          ),
        ),
        const SizedBox(width: Theming.offset),
        SizedBox(
          height: 40,
          child: Tooltip(
            message: 'Replies',
            child: InkResponse(
              radius: Theming.radiusSmall.x,
              onTap: widget.reply,
              child: Row(
                children: [
                  Text(
                    activity.replyCount.toString(),
                    style: TextTheme.of(context).labelSmall,
                  ),
                  const SizedBox(width: 5),
                  const Icon(Icons.reply_all_rounded, size: Theming.iconSmall),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: Theming.offset),
        SizedBox(
          height: 40,
          child: Tooltip(
            message: !activity.isLiked ? 'Like' : 'Unlike',
            child: InkResponse(
              radius: Theming.radiusSmall.x,
              onTap: _toggleLike,
              child: Row(
                children: [
                  Text(
                    activity.likeCount.toString(),
                    style: !activity.isLiked
                        ? TextTheme.of(context).labelSmall
                        : TextTheme.of(context).labelSmall!.copyWith(
                              color: ColorScheme.of(context).primary,
                            ),
                  ),
                  const SizedBox(width: 5),
                  Icon(
                    !widget.activity.isLiked
                        ? Icons.favorite_outline_rounded
                        : Icons.favorite_rounded,
                    size: Theming.iconSmall,
                    color: activity.isLiked
                        ? ColorScheme.of(context).primary
                        : null,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Show a sheet with additional options.
  void _showMoreSheet() {
    final activity = widget.activity;

    showSheet(
      context,
      Consumer(
        builder: (context, ref, _) {
          final ownershipButtons = <Widget>[];

          if (activity.isOwned) {
            if (activity is! MessageActivity) {
              ownershipButtons.add(ListTile(
                title:
                    activity.isPinned ? const Text('Unpin') : const Text('Pin'),
                leading: activity.isPinned
                    ? const Icon(Icons.push_pin)
                    : const Icon(Icons.push_pin_outlined),
                onTap: _togglePin,
              ));
            }

            if (activity.authorId == widget.viewerId) {
              switch (activity) {
                case StatusActivity _:
                  ownershipButtons.add(ListTile(
                    title: const Text('Edit'),
                    leading: const Icon(Icons.edit_outlined),
                    onTap: () => showSheet(
                      context,
                      CompositionView(
                        tag: StatusActivityCompositionTag(id: activity.id),
                        onSaved: (map) {
                          widget.onEdited?.call(map);
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ));
                case MessageActivity _:
                  ownershipButtons.add(ListTile(
                    title: const Text('Edit'),
                    leading: const Icon(Icons.edit_outlined),
                    onTap: () => showSheet(
                      context,
                      CompositionView(
                        tag: MessageActivityCompositionTag(
                          id: activity.id,
                          recipientId: activity.recipientId,
                        ),
                        onSaved: (map) {
                          widget.onEdited?.call(map);
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ));
                case MediaActivity _:
                  break;
              }
            }

            ownershipButtons.add(ListTile(
              title: const Text('Delete'),
              leading: const Icon(Ionicons.trash_outline),
              onTap: () => ConfirmationDialog.show(
                context,
                title: 'Delete?',
                primaryAction: 'Yes',
                secondaryAction: 'No',
                onConfirm: _remove,
              ),
            ));
          }

          return SimpleSheet.link(
            context,
            activity.siteUrl,
            [
              ...ownershipButtons,
              ListTile(
                title: !activity.isSubscribed
                    ? const Text('Subscribe')
                    : const Text('Unsubscribe'),
                leading: !activity.isSubscribed
                    ? const Icon(Ionicons.notifications_outline)
                    : const Icon(Ionicons.notifications_off_outline),
                onTap: _toggleSubscription,
              ),
            ],
          );
        },
      ),
    );
  }

  void _toggleLike() async {
    final activity = widget.activity;
    final isLiked = activity.isLiked;

    setState(() {
      activity.isLiked = !isLiked;
      activity.likeCount += isLiked ? -1 : 1;
    });

    final err = await widget.toggleLike();
    if (err == null) return;

    setState(() {
      activity.isLiked = isLiked;
      activity.likeCount += isLiked ? 1 : -1;
    });

    if (mounted) SnackBarExtension.show(context, err.toString());
  }

  void _toggleSubscription() {
    final activity = widget.activity;
    activity.isSubscribed = !activity.isSubscribed;

    widget.toggleSubscription().then((err) {
      if (err == null) {
        if (mounted) Navigator.pop(context);
        return;
      }

      activity.isSubscribed = !activity.isSubscribed;
      if (mounted) {
        SnackBarExtension.show(context, err.toString());
        Navigator.pop(context);
      }
    });
  }

  void _togglePin() {
    final activity = widget.activity;
    activity.isPinned = !activity.isPinned;

    widget.togglePin().then((err) {
      if (err == null) {
        if (mounted) Navigator.pop(context);
        return;
      }

      activity.isPinned = !activity.isPinned;
      if (mounted) {
        SnackBarExtension.show(context, err.toString());
        Navigator.pop(context);
      }
    });
  }

  void _remove() {
    widget.remove().then((err) {
      if (err == null) {
        if (mounted) Navigator.pop(context);
        return;
      }

      if (mounted) {
        SnackBarExtension.show(context, err.toString());
        Navigator.pop(context);
      }
    });
  }
}
