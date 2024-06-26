import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/util/extensions.dart';
import 'package:otraku/util/routes.dart';
import 'package:otraku/feature/user/user_models.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/widget/cached_image.dart';
import 'package:otraku/widget/layouts/top_bar.dart';
import 'package:otraku/widget/overlays/dialogs.dart';
import 'package:otraku/widget/overlays/sheets.dart';
import 'package:otraku/util/toast.dart';
import 'package:otraku/widget/text_rail.dart';

class UserHeader extends StatelessWidget {
  const UserHeader({
    required this.id,
    required this.isViewer,
    required this.user,
    required this.imageUrl,
    required this.toggleFollow,
  });

  final int? id;
  final bool isViewer;
  final User? user;
  final String? imageUrl;
  final Future<Object?> Function() toggleFollow;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
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
        textRailItems: textRailItems,
        topOffset: MediaQuery.paddingOf(context).top,
        imageWidth: size.width < 430.0 ? size.width * 0.30 : 100.0,
        toggleFollow: toggleFollow,
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
    required this.toggleFollow,
  });

  final int? id;
  final bool isViewer;
  final User? user;
  final String? imageUrl;
  final double topOffset;
  final double imageWidth;
  final Map<String, bool> textRailItems;
  final Future<Object?> Function() toggleFollow;

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

    final avatar = ClipRRect(
      borderRadius: Theming.borderRadiusSmall,
      child: SizedBox(
        height: imageWidth,
        width: imageWidth,
        child: image != null
            ? GestureDetector(
                onTap: () => showDialog(
                  context: context,
                  builder: (context) => ImageDialog(image),
                ),
                child: CachedImage(image, fit: BoxFit.contain),
              )
            : null,
      ),
    );

    final infoContent = Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        id != null ? Hero(tag: id!, child: avatar) : avatar,
        const SizedBox(width: Theming.offset),
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
                          color: theme.colorScheme.surface,
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
                    showDialog(
                      context: context,
                      builder: (context) => TextDialog(
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
            ? const SizedBox(width: Theming.offset)
            : TopBarIcon(
                tooltip: 'Close',
                icon: Icons.arrow_back_ios_new_rounded,
                onTap: context.back,
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
        if (!isViewer && user != null) _FollowButton(user!, toggleFollow),
        if (user?.siteUrl != null)
          TopBarIcon(
            tooltip: 'More',
            icon: Ionicons.ellipsis_horizontal,
            onTap: () => showSheet(
              context,
              SimpleSheet.link(context, user!.siteUrl!),
            ),
          ),
        if (isViewer)
          TopBarIcon(
            tooltip: 'Settings',
            icon: Ionicons.cog_outline,
            onTap: () => context.push(Routes.settings),
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
                    onTap: () => showDialog(
                      context: context,
                      builder: (context) => ImageDialog(user!.bannerUrl!),
                    ),
                  )
                : DecoratedBox(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
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
              color: theme.colorScheme.surface,
              child: Container(
                height: 0,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 15,
                      spreadRadius: 25,
                      color: theme.colorScheme.surface,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: Theming.offset,
            right: Theming.offset,
            child: infoContent,
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: topOffset + Theming.minTapTarget,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    theme.colorScheme.surface,
                    theme.colorScheme.surface.withAlpha(200),
                    theme.colorScheme.surface.withAlpha(0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: topOffset + Theming.minTapTarget,
            child: Opacity(
              opacity: transition,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                ),
              ),
            ),
          ),
        ],
        Positioned(
          left: 0,
          right: 0,
          top: topOffset,
          height: Theming.minTapTarget,
          child: topRow,
        ),
      ],
    );

    return transition < 1
        ? body
        : ClipRect(
            child: BackdropFilter(
              filter: Theming.blurFilter,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: theme.navigationBarTheme.backgroundColor,
                ),
                child: body,
              ),
            ),
          );
  }

  static const _bannerBaseHeight = 200.0;

  @override
  double get minExtent => topOffset + Theming.minTapTarget;

  @override
  double get maxExtent => topOffset + _bannerBaseHeight + imageWidth / 2;

  @override
  bool shouldRebuild(covariant _Delegate oldDelegate) =>
      user != oldDelegate.user;
}

class _FollowButton extends StatefulWidget {
  const _FollowButton(this.user, this.toggleFollow);

  final User user;
  final Future<Object?> Function() toggleFollow;

  @override
  State<_FollowButton> createState() => __FollowButtonState();
}

class __FollowButtonState extends State<_FollowButton> {
  @override
  Widget build(BuildContext context) {
    final user = widget.user;

    return Padding(
      padding: const EdgeInsets.all(Theming.offset),
      child: ElevatedButton.icon(
        icon: Icon(
          user.isFollowed
              ? Ionicons.person_remove_outline
              : Ionicons.person_add_outline,
          size: Theming.iconSmall,
        ),
        label: Text(
          user.isFollowed
              ? user.isFollower
                  ? 'Mutual'
                  : 'Following'
              : user.isFollower
                  ? 'Follower'
                  : 'Follow',
        ),
        onPressed: () {
          final isFollowed = user.isFollowed;
          setState(() => user.isFollowed = !isFollowed);

          widget.toggleFollow().then((err) {
            if (err == null) return;

            setState(() => user.isFollowed = isFollowed);

            if (context.mounted) Toast.show(context, err.toString());
          });
        },
      ),
    );
  }
}
