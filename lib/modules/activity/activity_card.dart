import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/modules/activity/activity_models.dart';
import 'package:otraku/modules/activity/activity_provider.dart';
import 'package:otraku/modules/composition/composition_model.dart';
import 'package:otraku/modules/composition/composition_view.dart';
import 'package:otraku/common/utils/consts.dart';
import 'package:otraku/modules/discover/discover_models.dart';
import 'package:otraku/common/widgets/link_tile.dart';
import 'package:otraku/common/widgets/cached_image.dart';
import 'package:otraku/common/widgets/html_content.dart';
import 'package:otraku/common/widgets/overlays/dialogs.dart';
import 'package:otraku/common/widgets/overlays/sheets.dart';

class ActivityCard extends StatelessWidget {
  const ActivityCard({
    required this.activity,
    required this.footer,
    required this.withHeader,
  });

  final Activity activity;
  final ActivityFooter footer;
  final bool withHeader;

  @override
  Widget build(BuildContext context) {
    final body = Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
        child: Column(
          children: [
            if (activity is MediaActivity)
              _ActivityMediaBox(activity as MediaActivity)
            else
              HtmlContent(activity.text),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    activity.createdAt,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ),
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
              child: LinkTile(
                id: activity.authorId,
                info: activity.authorAvatarUrl,
                discoverType: DiscoverType.User,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipRRect(
                      borderRadius: Consts.borderRadiusMin,
                      child: CachedImage(
                        activity.authorAvatarUrl,
                        height: 50,
                        width: 50,
                      ),
                    ),
                    const SizedBox(width: 10),
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
                      padding: EdgeInsets.only(left: 10),
                      child: Icon(Ionicons.eye_off_outline),
                    ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Icon(Icons.arrow_right_alt),
                  ),
                  LinkTile(
                    id: message.recipientId,
                    info: message.recipientAvatarUrl,
                    discoverType: DiscoverType.User,
                    child: ClipRRect(
                      borderRadius: Consts.borderRadiusMin,
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
                    padding: EdgeInsets.only(left: 10),
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
    return LinkTile(
      id: item.id,
      info: item.coverUrl,
      discoverType: item.isAnime ? DiscoverType.Anime : DiscoverType.Manga,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 108),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: Consts.borderRadiusMin,
              child: CachedImage(item.coverUrl, width: 70),
            ),
            Expanded(
              child: Padding(
                padding: Consts.padding,
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
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                            TextSpan(
                              text: item.title,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (item.format != null) ...[
                      const SizedBox(height: 5),
                      Text(
                        item.format!,
                        style: Theme.of(context).textTheme.labelMedium,
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
    required this.activity,
    required this.onDeleted,
    required this.onPinned,
    required this.onChanged,
    required this.onOpenReplies,
    required this.onEdited,
  });

  final Activity activity;
  final void Function() onDeleted;
  final void Function()? onPinned;
  final void Function()? onChanged;
  final void Function()? onOpenReplies;
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
              radius: 10,
              onTap: _showMoreSheet,
              child: const Icon(
                Ionicons.ellipsis_horizontal,
                size: Consts.iconSmall,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          height: 40,
          child: Tooltip(
            message: 'Replies',
            child: InkResponse(
              radius: 10,
              onTap: widget.onOpenReplies,
              child: Row(
                children: [
                  Text(
                    activity.replyCount.toString(),
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  const SizedBox(width: 5),
                  const Icon(Ionicons.chatbox, size: Consts.iconSmall),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          height: 40,
          child: Tooltip(
            message: !activity.isLiked ? 'Like' : 'Unlike',
            child: InkResponse(
              radius: 10,
              onTap: _toggleLike,
              child: Row(
                children: [
                  Text(
                    activity.likeCount.toString(),
                    style: !activity.isLiked
                        ? Theme.of(context).textTheme.labelSmall
                        : Theme.of(context).textTheme.labelSmall!.copyWith(
                            color: Theme.of(context).colorScheme.error),
                  ),
                  const SizedBox(width: 5),
                  Icon(
                    Icons.favorite,
                    size: Consts.iconSmall,
                    color: activity.isLiked
                        ? Theme.of(context).colorScheme.error
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

  void _toggleLike() {
    final activity = widget.activity;
    final isLiked = activity.isLiked;

    setState(() {
      activity.isLiked = !isLiked;
      activity.likeCount += isLiked ? -1 : 1;
    });

    toggleActivityLike(activity).then((err) {
      if (err == null) {
        widget.onChanged?.call();
        return;
      }

      setState(() {
        activity.isLiked = isLiked;
        activity.likeCount += isLiked ? 1 : -1;
      });

      showPopUp(
        context,
        ConfirmationDialog(
          title: 'Could not toggle like',
          content: err.toString(),
        ),
      );
    });
  }

  /// Show a sheet with additional options.
  void _showMoreSheet() {
    final activity = widget.activity;

    showSheet(
      context,
      Consumer(
        builder: (context, ref, __) {
          final ownershipButtons = <Widget>[];
          if (activity.isOwned) {
            switch (activity) {
              case StatusActivity _:
                ownershipButtons.add(GradientSheetButton(
                  text: 'Edit',
                  icon: Icons.edit_outlined,
                  onTap: () => showSheet(
                    context,
                    CompositionView(
                      composition: Composition.status(
                        activity.id,
                        activity.text,
                      ),
                      onDone: (map) => widget.onEdited?.call(map),
                    ),
                  ),
                ));
              case MessageActivity _:
                ownershipButtons.add(GradientSheetButton(
                  text: 'Edit',
                  icon: Icons.edit_outlined,
                  onTap: () => showSheet(
                    context,
                    CompositionView(
                      composition: Composition.message(
                        activity.id,
                        activity.text,
                        activity.recipientId,
                      ),
                      onDone: (map) => widget.onEdited?.call(map),
                    ),
                  ),
                ));
              case MediaActivity _:
                break;
            }

            ownershipButtons.add(GradientSheetButton(
              text: 'Delete',
              icon: Ionicons.trash_outline,
              onTap: () => showPopUp(
                context,
                ConfirmationDialog(
                  title: 'Delete?',
                  mainAction: 'Yes',
                  secondaryAction: 'No',
                  onConfirm: () {
                    deleteActivity(widget.activity.id).then((err) {
                      err == null
                          ? widget.onDeleted()
                          : showPopUp(
                              context,
                              ConfirmationDialog(
                                title: 'Could not delete activity',
                                content: err.toString(),
                              ),
                            );
                    });
                  },
                ),
              ),
            ));
          }

          return GradientSheet.link(
            context,
            activity.siteUrl,
            [
              ...ownershipButtons,
              if (widget.onPinned != null &&
                  activity.isOwned &&
                  activity is! MessageActivity)
                GradientSheetButton(
                  text: activity.isPinned ? 'Unpin' : 'Pin',
                  icon: activity.isPinned
                      ? Icons.push_pin
                      : Icons.push_pin_outlined,
                  onTap: () {
                    final isPinned = activity.isPinned;
                    activity.isPinned = !isPinned;

                    toggleActivityPin(activity).then((err) {
                      if (err == null) {
                        widget.onPinned!();
                        return;
                      }

                      activity.isPinned = isPinned;
                      showPopUp(
                        context,
                        ConfirmationDialog(
                          title: 'Could not toggle pin',
                          content: err.toString(),
                        ),
                      );
                    });
                  },
                ),
              GradientSheetButton(
                text: !activity.isSubscribed ? 'Subscribe' : 'Unsubscribe',
                icon: !activity.isSubscribed
                    ? Ionicons.notifications_outline
                    : Ionicons.notifications_off_outline,
                onTap: () {
                  final isSubscribed = activity.isSubscribed;
                  activity.isSubscribed = !isSubscribed;

                  toggleActivitySubscription(activity).then((err) {
                    if (err == null) {
                      widget.onChanged?.call();
                      return;
                    }

                    activity.isSubscribed = isSubscribed;
                    showPopUp(
                      context,
                      ConfirmationDialog(
                        title: 'Could not toggle subscription',
                        content: err.toString(),
                      ),
                    );
                  });
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
