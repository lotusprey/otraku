import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/common/utils/consts.dart';
import 'package:otraku/modules/user/user_models.dart';
import 'package:otraku/modules/user/user_providers.dart';
import 'package:otraku/common/utils/route_arg.dart';
import 'package:otraku/common/widgets/cached_image.dart';
import 'package:otraku/common/widgets/layouts/top_bar.dart';
import 'package:otraku/common/widgets/overlays/dialogs.dart';
import 'package:otraku/common/widgets/overlays/sheets.dart';
import 'package:otraku/common/widgets/overlays/toast.dart';
import 'package:otraku/common/widgets/text_rail.dart';

class UserHeader extends StatelessWidget {
  const UserHeader({
    required this.id,
    required this.isViewer,
    required this.user,
    required this.imageUrl,
  });

  final int id;
  final bool isViewer;
  final User? user;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final topOffset = MediaQuery.of(context).padding.top;
    final textRailItems = <String, bool>{};
    if (user != null) {
      if (user!.modRoles.isNotEmpty) textRailItems[user!.modRoles[0]] = false;
      if (user!.donatorTier > 0) textRailItems[user!.donatorBadge] = true;
    }

    return SliverPersistentHeader(
      pinned: true,
      delegate: _Delegate(
        id: id,
        isViewer: isViewer,
        user: user,
        imageUrl: imageUrl,
        topOffset: topOffset,
        textRailItems: textRailItems,
        imageWidth: MediaQuery.of(context).size.width < 430.0
            ? MediaQuery.of(context).size.width * 0.30
            : 100.0,
      ),
    );
  }
}

class _Delegate extends SliverPersistentHeaderDelegate {
  _Delegate({
    required this.id,
    required this.isViewer,
    required this.user,
    required this.imageUrl,
    required this.topOffset,
    required this.imageWidth,
    required this.textRailItems,
  });

  final int id;
  final bool isViewer;
  final User? user;
  final String? imageUrl;
  final double topOffset;
  final double imageWidth;
  final Map<String, bool> textRailItems;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final height = maxExtent;
    final bannerOffset = height - _bannerBaseHeight - topOffset;

    var transition = shrinkOffset > _bannerBaseHeight
        ? (shrinkOffset - _bannerBaseHeight) / (imageWidth / 4)
        : 0.0;
    if (transition > 1) transition = 1;

    final image = user?.imageUrl ?? imageUrl;
    final theme = Theme.of(context);

    final infoContent = Row(
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
                      child: CachedImage(image, fit: BoxFit.contain),
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
              if (user != null) ...[
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Toast.copy(context, user!.name),
                  child: Text(
                    user!.name,
                    overflow: TextOverflow.fade,
                    style: theme.textTheme.titleLarge!.copyWith(
                      shadows: [
                        Shadow(
                          blurRadius: 10,
                          color: theme.colorScheme.background,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 5),
              ],
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
    );

    final topRow = Row(
      children: [
        isViewer
            ? const SizedBox(width: 10)
            : TopBarIcon(
                tooltip: 'Close',
                icon: Ionicons.chevron_back_outline,
                onTap: Navigator.of(context).pop,
              ),
        Expanded(
          child: user?.name == null
              ? const SizedBox()
              : Opacity(
                  opacity: transition,
                  child: Text(
                    user!.name,
                    style: theme.textTheme.titleMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
        ),
        if (!isViewer && user != null) _FollowButton(user!),
        if (user?.siteUrl != null)
          TopBarIcon(
            tooltip: 'More',
            icon: Ionicons.ellipsis_horizontal,
            onTap: () => showSheet(
              context,
              GradientSheet.link(context, user!.siteUrl!),
            ),
          ),
        if (isViewer)
          TopBarIcon(
            tooltip: 'Settings',
            icon: Ionicons.cog_outline,
            onTap: () => Navigator.pushNamed(
              context,
              RouteArg.settings,
            ),
          ),
      ],
    );

    final body = Stack(
      fit: StackFit.expand,
      children: [
        if (transition < 1) ...[
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: bannerOffset,
            child: user?.bannerUrl != null
                ? GestureDetector(
                    child: CachedImage(user!.bannerUrl!),
                    onTap: () => showPopUp(
                      context,
                      ImageDialog(user!.bannerUrl!),
                    ),
                  )
                : DecoratedBox(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceVariant,
                    ),
                  ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: bannerOffset,
            child: Container(
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
            left: 10,
            right: 10,
            child: infoContent,
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: topOffset + Consts.tapTargetSize,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    theme.colorScheme.background,
                    theme.colorScheme.background.withAlpha(200),
                    theme.colorScheme.background.withAlpha(0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: topOffset + Consts.tapTargetSize,
            child: Opacity(
              opacity: transition,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: theme.colorScheme.background,
                ),
              ),
            ),
          ),
        ],
        Positioned(
          left: 0,
          right: 0,
          top: topOffset,
          height: Consts.tapTargetSize,
          child: topRow,
        ),
      ],
    );

    return transition < 1
        ? body
        : ClipRect(
            child: BackdropFilter(
              filter: Consts.blurFilter,
              child: DecoratedBox(
                decoration: BoxDecoration(color: theme.bottomAppBarTheme.color),
                child: body,
              ),
            ),
          );
  }

  static const _bannerBaseHeight = 200.0;

  @override
  double get minExtent => topOffset + Consts.tapTargetSize;

  @override
  double get maxExtent => topOffset + _bannerBaseHeight + imageWidth / 2;

  @override
  bool shouldRebuild(covariant _Delegate oldDelegate) =>
      user != oldDelegate.user;
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
