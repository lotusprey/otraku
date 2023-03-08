import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/utils/consts.dart';
import 'package:otraku/user/user_models.dart';
import 'package:otraku/user/user_providers.dart';
import 'package:otraku/utils/route_arg.dart';
import 'package:otraku/widgets/fade_image.dart';
import 'package:otraku/widgets/layouts/top_bar.dart';
import 'package:otraku/widgets/overlays/dialogs.dart';
import 'package:otraku/widgets/overlays/sheets.dart';
import 'package:otraku/widgets/overlays/toast.dart';
import 'package:otraku/widgets/text_rail.dart';

class UserHeader extends StatelessWidget {
  const UserHeader({
    required this.id,
    required this.isMe,
    required this.user,
    required this.imageUrl,
  });

  final int id;
  final bool isMe;
  final User? user;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final textRailItems = <String, bool>{};
    if (user != null) {
      if (user!.modRoles.isNotEmpty) textRailItems[user!.modRoles[0]] = false;
      if (user!.donatorTier > 0) textRailItems[user!.donatorBadge] = true;
    }

    return SliverPersistentHeader(
      pinned: true,
      delegate: _Delegate(
        id: id,
        isMe: isMe,
        user: user,
        imageUrl: imageUrl,
        textRailItems: textRailItems,
        imageWidth: MediaQuery.of(context).size.width < 430.0
            ? MediaQuery.of(context).size.width * 0.30
            : 100.0,
      ),
    );
  }
}

class _Delegate implements SliverPersistentHeaderDelegate {
  _Delegate({
    required this.id,
    required this.isMe,
    required this.user,
    required this.imageUrl,
    required this.imageWidth,
    required this.textRailItems,
  });

  final int id;
  final bool isMe;
  final User? user;
  final String? imageUrl;
  final double imageWidth;
  final Map<String, bool> textRailItems;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final sidePadding =
        MediaQuery.of(context).size.width > Consts.layoutBig + 20
            ? (MediaQuery.of(context).size.width - Consts.layoutBig) / 2
            : 10.0;

    final height = maxExtent;
    final extent = maxExtent - shrinkOffset;
    final opacity = shrinkOffset < (_bannerHeight - minExtent)
        ? shrinkOffset / (_bannerHeight - minExtent)
        : 1.0;

    final image = user?.imageUrl ?? imageUrl;
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant,
        boxShadow: [
          BoxShadow(
            blurRadius: 5,
            spreadRadius: 5,
            color: theme.colorScheme.background,
          ),
        ],
      ),
      child: FlexibleSpaceBar.createSettings(
        minExtent: minExtent,
        maxExtent: maxExtent,
        currentExtent: extent > minExtent ? extent : minExtent,
        child: Stack(
          fit: StackFit.expand,
          children: [
            FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              stretchModes: const [StretchMode.zoomBackground],
              background: Column(
                children: [
                  Expanded(
                    child: user?.bannerUrl != null
                        ? GestureDetector(
                            child: FadeImage(user!.bannerUrl!),
                            onTap: () => showPopUp(
                              context,
                              ImageDialog(user!.bannerUrl!),
                            ),
                          )
                        : const SizedBox(),
                  ),
                  SizedBox(height: height - _bannerHeight),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: height - _bannerHeight,
                alignment: Alignment.topCenter,
                color: theme.colorScheme.background,
                child: Container(
                  height: 0,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 15,
                        spreadRadius: 25,
                        color: theme.colorScheme.background,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: sidePadding,
              right: sidePadding,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Hero(
                    tag: id,
                    child: ClipRRect(
                      borderRadius: Consts.borderRadiusMin,
                      child: SizedBox(
                        height: imageWidth,
                        width: imageWidth,
                        child: image != null
                            ? GestureDetector(
                                onTap: () => showPopUp(
                                  context,
                                  ImageDialog(image),
                                ),
                                child: FadeImage(
                                  image,
                                  fit: BoxFit.contain,
                                  alignment: Alignment.bottomCenter,
                                ),
                              )
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (user != null)
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => Toast.copy(context, user!.name),
                            child: Text(
                              user!.name,
                              overflow: TextOverflow.fade,
                              style: theme.textTheme.titleLarge!.copyWith(
                                shadows: [
                                  Shadow(
                                    color: theme.colorScheme.background,
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        if (textRailItems.isNotEmpty)
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              if (user?.modRoles.isNotEmpty ?? false) {
                                showPopUp(
                                  context,
                                  TextDialog(
                                    title: 'Roles',
                                    text: user!.modRoles.join(', '),
                                  ),
                                );
                              }
                            },
                            child: TextRail(
                              textRailItems,
                              style: theme.textTheme.labelMedium,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: minExtent,
              child: Opacity(
                opacity: opacity,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.background,
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 10,
                        spreadRadius: 10,
                        color: theme.colorScheme.background,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: minExtent,
              child: Row(
                children: [
                  isMe
                      ? const SizedBox(width: 10)
                      : TopBarShadowIcon(
                          tooltip: 'Close',
                          icon: Ionicons.chevron_back_outline,
                          onTap: Navigator.of(context).pop,
                        ),
                  Expanded(
                    child: user?.name == null
                        ? const SizedBox()
                        : Opacity(
                            opacity: opacity,
                            child: Text(
                              user!.name,
                              style: theme.textTheme.titleMedium,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                  ),
                  if (!isMe && user != null) _FollowButton(user!),
                  if (user?.siteUrl != null)
                    TopBarShadowIcon(
                      tooltip: 'More',
                      icon: Ionicons.ellipsis_horizontal,
                      onTap: () => showSheet(
                        context,
                        FixedGradientDragSheet.link(context, user!.siteUrl!),
                      ),
                    ),
                  if (isMe)
                    TopBarShadowIcon(
                      tooltip: 'Settings',
                      icon: Ionicons.cog_outline,
                      onTap: () => Navigator.pushNamed(
                        context,
                        RouteArg.settings,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const _bannerHeight = 200.0;

  @override
  double get maxExtent => _bannerHeight + imageWidth / 2;

  @override
  double get minExtent => Consts.tapTargetSize;

  @override
  OverScrollHeaderStretchConfiguration? get stretchConfiguration =>
      OverScrollHeaderStretchConfiguration(stretchTriggerOffset: 100);

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      true;

  @override
  PersistentHeaderShowOnScreenConfiguration? get showOnScreenConfiguration =>
      null;

  @override
  FloatingHeaderSnapConfiguration? get snapConfiguration => null;

  @override
  TickerProvider? get vsync => null;
}

class _FollowButton extends StatefulWidget {
  const _FollowButton(this.user);

  final User user;

  @override
  State<_FollowButton> createState() => __FollowButtonState();
}

class __FollowButtonState extends State<_FollowButton> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: ElevatedButton.icon(
        icon: Icon(
          widget.user.isFollowed
              ? Ionicons.person_remove_outline
              : Ionicons.person_add_outline,
          size: Consts.iconSmall,
        ),
        label: Text(
          widget.user.isFollowed
              ? widget.user.isFollower
                  ? 'Mutual'
                  : 'Following'
              : widget.user.isFollower
                  ? 'Follower'
                  : 'Follow',
        ),
        onPressed: () {
          final isFollowed = widget.user.isFollowed;
          setState(() => widget.user.isFollowed = !isFollowed);
          toggleFollow(widget.user.id).then((ok) {
            if (!ok) setState(() => widget.user.isFollowed = isFollowed);
          });
        },
      ),
    );
  }
}
