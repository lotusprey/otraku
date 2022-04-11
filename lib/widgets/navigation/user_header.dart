import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/controllers/home_controller.dart';
import 'package:otraku/constants/consts.dart';
import 'package:otraku/controllers/user_controller.dart';
import 'package:otraku/models/user_model.dart';
import 'package:otraku/utils/route_arg.dart';
import 'package:otraku/widgets/navigation/app_bars.dart';
import 'package:otraku/widgets/navigation/custom_sliver_header.dart';
import 'package:otraku/widgets/overlays/dialogs.dart';
import 'package:otraku/widgets/overlays/sheets.dart';

class UserHeader extends StatelessWidget {
  final int id;
  final UserModel? user;
  final bool isMe;
  final String? avatarUrl;

  UserHeader({
    required this.id,
    required this.user,
    required this.isMe,
    required this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return CustomSliverHeader(
      title: user?.name,
      image: user?.avatar ?? avatarUrl,
      banner: user?.banner,
      squareImage: true,
      implyLeading: !isMe,
      heroId: id,
      actions: [
        if (!isMe && user != null)
          Padding(
            padding: const EdgeInsets.all(10),
            child: ElevatedButton.icon(
              icon: Icon(
                user!.isFollowing
                    ? Ionicons.person_remove_outline
                    : Ionicons.person_add_outline,
                size: Consts.ICON_SMALL,
              ),
              label: Text(
                user!.isFollowing
                    ? user!.isFollower
                        ? 'Mutual'
                        : 'Following'
                    : user!.isFollower
                        ? 'Follower'
                        : 'Follow',
              ),
              onPressed:
                  Get.find<UserController>(tag: id.toString()).toggleFollow,
            ),
          ),
        if (user?.siteUrl != null)
          IconShade(AppBarIcon(
            tooltip: 'More',
            icon: Ionicons.ellipsis_horizontal,
            onTap: () => showSheet(
              context,
              FixedGradientDragSheet.link(context, user!.siteUrl!),
            ),
          )),
        if (isMe)
          GetBuilder<HomeController>(
            id: HomeController.ID_SETTINGS,
            builder: (ctrl) {
              if (ctrl.siteSettings == null) return const SizedBox();

              return IconShade(
                AppBarIcon(
                  tooltip: 'Settings',
                  icon: Ionicons.cog_outline,
                  onTap: () => Navigator.pushNamed(context, RouteArg.settings),
                ),
              );
            },
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
                if (user!.donatorTier > 0) _AnimatedBadge(user!.donatorBadge),
                if (user!.modRoles.isNotEmpty)
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      margin: const EdgeInsets.only(top: 5),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: Consts.BORDER_RAD_MIN,
                      ),
                      child: Text(
                        user!.modRoles[0],
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.button,
                      ),
                    ),
                    onTap: () => showPopUp(
                      context,
                      TextDialog(
                        title: 'Roles',
                        text: user!.modRoles.join(', '),
                      ),
                    ),
                  ),
              ]
            : [],
      ),
    );
  }
}

class _AnimatedBadge extends StatefulWidget {
  final String? text;
  _AnimatedBadge(this.text);

  @override
  __AnimatedBadgeState createState() => __AnimatedBadgeState();
}

class __AnimatedBadgeState extends State<_AnimatedBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<Color?> _animation;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );

    const weight = 12.5;

    _animation = TweenSequence([
      TweenSequenceItem(
        tween: ColorTween(begin: Color(0xFF03E7FC), end: Color(0xFF0055FF)),
        weight: weight,
      ),
      TweenSequenceItem(
        tween: ColorTween(begin: Color(0xFF0055FF), end: Color(0xFF9900FF)),
        weight: weight,
      ),
      TweenSequenceItem(
        tween: ColorTween(begin: Color(0xFF9900FF), end: Color(0xFFFF00A2)),
        weight: weight,
      ),
      TweenSequenceItem(
        tween: ColorTween(begin: Color(0xFFFF00A2), end: Color(0xFFFF0400)),
        weight: weight,
      ),
      TweenSequenceItem(
        tween: ColorTween(begin: Color(0xFFFF0400), end: Color(0xFFFF8400)),
        weight: weight,
      ),
      TweenSequenceItem(
        tween: ColorTween(begin: Color(0xFFFF8400), end: Color(0xFFFCDB03)),
        weight: weight,
      ),
      TweenSequenceItem(
        tween: ColorTween(begin: Color(0xFFFCDB03), end: Color(0xFF00FF4C)),
        weight: weight,
      ),
      TweenSequenceItem(
        tween: ColorTween(begin: Color(0xFF00FF4C), end: Color(0xFF03E7FC)),
        weight: weight,
      ),
    ]).animate(_ctrl)
      ..addListener(() => setState(() {}));

    _ctrl.repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 5),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _animation.value,
        borderRadius: Consts.BORDER_RAD_MIN,
      ),
      child: Text(
        widget.text!,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context)
            .textTheme
            .headline3!
            .copyWith(color: Colors.white),
      ),
    );
  }
}
