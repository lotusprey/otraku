import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otraku/controllers/config.dart';
import 'package:otraku/controllers/user.dart';
import 'package:otraku/enums/themes.dart';
import 'package:otraku/models/anilist/user_model.dart';
import 'package:otraku/pages/settings/settings_page.dart';
import 'package:otraku/tools/fade_image.dart';
import 'package:otraku/tools/navigation/custom_sliver_header.dart';
import 'package:otraku/tools/overlays/dialogs.dart';

class UserHeader extends StatelessWidget {
  final int id;
  final UserModel user;
  final bool isMe;
  final String avatarUrl;

  UserHeader({
    @required this.id,
    @required this.user,
    @required this.isMe,
    @required this.avatarUrl,
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
      actionsScrollFadeIn: false,
      title: user?.name,
      actions: [
        if (isMe)
          IconShade(IconButton(
            tooltip: 'Settings',
            icon: const Icon(FluentSystemIcons.ic_fluent_settings_regular),
            color: Theme.of(context).dividerColor,
            onPressed: () => Get.toNamed(SettingsPage.ROUTE),
          ))
        else if (user != null)
          Padding(
            padding: const EdgeInsets.only(right: 10, top: 8, bottom: 8),
            child: ElevatedButton(
              child: Text(
                user.following
                    ? user.follower
                        ? 'Mutual'
                        : 'Unfollow'
                    : 'Follow',
                style: TextStyle(fontSize: Styles.FONT_MEDIUM),
              ),
              onPressed: Get.find<User>(tag: id.toString()).toggleFollow,
            ),
          )
      ],
      background: Stack(
        fit: StackFit.expand,
        children: [
          Column(
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(color: Theme.of(context).primaryColor),
                    if (user?.banner != null)
                      FadeImage(user.banner, height: bannerHeight)
                  ],
                ),
              ),
              SizedBox(height: height - bannerHeight),
            ],
          ),
          Positioned.fill(
            bottom: height - bannerHeight - 1,
            child: Container(
              height: bannerHeight,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.transparent,
                    Theme.of(context).backgroundColor,
                  ],
                ),
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
                        borderRadius: Config.BORDER_RADIUS,
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
                    onTap: () => showDialog(
                      context: context,
                      builder: (_) => PopUpAnimation(
                        ImageDialog(Image.network(avatar, fit: BoxFit.cover)),
                      ),
                    ),
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
                          user.name,
                          overflow: TextOverflow.fade,
                          style: Theme.of(context).textTheme.headline2,
                        ),
                      ),
                      if (user.donatorTier > 0)
                        Flexible(child: _AnimatedBadge(user.donatorBadge)),
                      if (user.moderatorStatus != null)
                        Flexible(
                          child: Container(
                            margin: const EdgeInsets.only(top: 5),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).accentColor,
                              borderRadius: Config.BORDER_RADIUS,
                            ),
                            child: Text(
                              user.moderatorStatus,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle2
                                  .copyWith(
                                    color: Theme.of(context).backgroundColor,
                                    fontWeight: FontWeight.w500,
                                  ),
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
  final String text;
  _AnimatedBadge(this.text);

  @override
  __AnimatedBadgeState createState() => __AnimatedBadgeState();
}

class __AnimatedBadgeState extends State<_AnimatedBadge>
    with SingleTickerProviderStateMixin {
  AnimationController _ctrl;
  Animation<Color> _animation;

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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _animation.value,
        borderRadius: Config.BORDER_RADIUS,
      ),
      child: Text(
        widget.text,
        overflow: TextOverflow.ellipsis,
        style:
            Theme.of(context).textTheme.headline6.copyWith(color: Colors.white),
      ),
    );
  }
}
