import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/controllers/home_controller.dart';
import 'package:otraku/constants/consts.dart';
import 'package:otraku/controllers/user_controller.dart';
import 'package:otraku/models/user_model.dart';
import 'package:otraku/utils/route_arg.dart';
import 'package:otraku/utils/theming.dart';
import 'package:otraku/widgets/fade_image.dart';
import 'package:otraku/widgets/navigation/app_bars.dart';
import 'package:otraku/widgets/navigation/custom_sliver_header.dart';
import 'package:otraku/widgets/overlays/dialogs.dart';

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
    const avatarSize = 150.0;
    double bannerHeight = MediaQuery.of(context).size.width * 0.6;
    if (bannerHeight > 400) bannerHeight = 400;
    final height = bannerHeight + avatarSize * 0.5;
    final avatar = avatarUrl ?? user?.avatar;

    return CustomSliverHeader(
      height: height,
      implyLeading: !isMe,
      title: user?.name,
      actions: [
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
          )
        else if (user != null)
          Padding(
            padding: const EdgeInsets.all(10),
            child: ElevatedButton.icon(
              icon: Icon(
                user!.isFollowing
                    ? Ionicons.person_remove_outline
                    : Ionicons.person_add_outline,
                size: Theming.ICON_SMALL,
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
          )
      ],
      background: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration:
                BoxDecoration(color: Theme.of(context).colorScheme.surface),
          ),
          if (user?.banner != null)
            Column(
              children: [
                Expanded(
                  child: GestureDetector(
                    child: FadeImage(user!.banner!),
                    onTap: () => showPopUp(context, ImageDialog(user!.banner!)),
                  ),
                ),
                SizedBox(height: height - bannerHeight),
              ],
            ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: height - bannerHeight,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.background,
                boxShadow: [
                  BoxShadow(
                    blurRadius: 15,
                    spreadRadius: 25,
                    color: Theme.of(context).colorScheme.background,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            avatar != null
                ? GestureDetector(
                    child: Hero(
                      tag: id,
                      child: ClipRRect(
                        borderRadius: Consts.BORDER_RADIUS,
                        child: Container(
                          height: avatarSize,
                          width: avatarSize,
                          child: FadeImage(
                            avatar,
                            fit: BoxFit.contain,
                            alignment: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ),
                    onTap: () => showPopUp(context, ImageDialog(avatar)),
                  )
                : SizedBox(width: avatarSize),
            const SizedBox(width: 10),
            if (user != null)
              Expanded(
                child: SizedBox(
                  height: avatarSize,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                        flex: 3,
                        child: Text(
                          user!.name!,
                          overflow: TextOverflow.fade,
                          style:
                              Theme.of(context).textTheme.headline1!.copyWith(
                            shadows: [
                              Shadow(
                                color: Theme.of(context).colorScheme.background,
                                blurRadius: 10,
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (user!.donatorTier! > 0)
                        Flexible(child: _AnimatedBadge(user!.donatorBadge)),
                      if (user!.moderatorStatus != null)
                        Flexible(
                          child: Container(
                            margin: const EdgeInsets.only(top: 5),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.secondary,
                              borderRadius: Consts.BORDER_RADIUS,
                            ),
                            child: Text(
                              user!.moderatorStatus!,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.button,
                            ),
                          ),
                        ),
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
        borderRadius: Consts.BORDER_RADIUS,
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
