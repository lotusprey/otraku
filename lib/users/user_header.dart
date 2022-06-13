import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/constants/consts.dart';
import 'package:otraku/users/user.dart';
import 'package:otraku/utils/route_arg.dart';
import 'package:otraku/widgets/layouts/page_layout.dart';
import 'package:otraku/widgets/navigation/custom_sliver_header.dart';
import 'package:otraku/widgets/overlays/dialogs.dart';
import 'package:otraku/widgets/overlays/sheets.dart';

class UserHeader extends StatelessWidget {
  UserHeader({
    required this.id,
    required this.user,
    required this.isMe,
    required this.imageUrl,
  });

  final int id;
  final User? user;
  final bool isMe;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final textRailItems = <String, bool>{};
    if (user != null) {
      if (user!.modRoles.isNotEmpty) textRailItems[user!.modRoles[0]] = false;
      if (user!.donatorTier > 0) textRailItems[user!.donatorBadge] = true;
    }

    return CustomSliverHeader(
      title: user?.name,
      image: user?.imageUrl ?? imageUrl,
      banner: user?.bannerUrl,
      squareImage: true,
      implyLeading: !isMe,
      heroId: id,
      actions: [
        if (!isMe && user != null) _FollowButton(user!),
        if (user?.siteUrl != null)
          IconShade(TopBarIcon(
            tooltip: 'More',
            icon: Ionicons.ellipsis_horizontal,
            onTap: () => showSheet(
              context,
              FixedGradientDragSheet.link(context, user!.siteUrl!),
            ),
          )),
        if (isMe)
          IconShade(
            TopBarIcon(
              tooltip: 'Settings',
              icon: Ionicons.cog_outline,
              onTap: () => Navigator.pushNamed(context, RouteArg.settings),
            ),
          ),
      ],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: user != null
            ? [
                Text(
                  user!.name,
                  overflow: TextOverflow.fade,
                  style: Theme.of(context).textTheme.headline1!.copyWith(
                    shadows: [
                      Shadow(
                        color: Theme.of(context).colorScheme.background,
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),
                if (textRailItems.isNotEmpty)
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      if (user!.modRoles.isNotEmpty)
                        showPopUp(
                          context,
                          TextDialog(
                            title: 'Roles',
                            text: user!.modRoles.join(', '),
                          ),
                        );
                    },
                    child: TextRail(textRailItems),
                  ),
              ]
            : [],
      ),
    );
  }
}

class _FollowButton extends StatefulWidget {
  _FollowButton(this.user);

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
