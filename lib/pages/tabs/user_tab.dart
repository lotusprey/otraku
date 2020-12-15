import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:otraku/models/user.dart';
import 'package:otraku/pages/pushable/settings_page.dart';
import 'package:otraku/pages/tab_manager.dart';
import 'package:otraku/controllers/users.dart';
import 'package:otraku/controllers/config.dart';
import 'package:otraku/tools/overlays/dialogs.dart';
import 'package:otraku/tools/page_transition.dart';
import 'package:otraku/models/transparent_image.dart';

class UserTab extends StatelessWidget {
  final _space = const SizedBox(width: 10);

  final int id;
  final String avatarUrl;

  const UserTab(this.id, this.avatarUrl);

  @override
  Widget build(BuildContext context) => Obx(() {
        final users = Get.find<Users>();
        final user = id == null ? users.me : users.them(id);

        return CustomScrollView(
          physics: Config.PHYSICS,
          slivers: [
            SliverPersistentHeader(
              delegate: _Header(
                id: id,
                user: user,
                isMe: id == null,
                avatarUrl: avatarUrl,
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    Expanded(
                      child: RaisedButton(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              FluentSystemIcons.ic_fluent_movies_and_tv_regular,
                              color: Theme.of(context).backgroundColor,
                            ),
                            _space,
                            Text('Anime',
                                style: Theme.of(context).textTheme.button),
                          ],
                        ),
                        onPressed: () => id == null
                            ? Config.pageIndex = TabManager.ANIME_LIST
                            : print('TODO'),
                      ),
                    ),
                    _space,
                    Expanded(
                      child: RaisedButton(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              FluentSystemIcons.ic_fluent_bookmark_regular,
                              color: Theme.of(context).backgroundColor,
                            ),
                            _space,
                            Text('Manga',
                                style: Theme.of(context).textTheme.button),
                          ],
                        ),
                        onPressed: () => id == null
                            ? Config.pageIndex = TabManager.MANGA_LIST
                            : print('TODO'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: const SizedBox(height: 60),
            ),
          ],
        );
      });
}

class _Header implements SliverPersistentHeaderDelegate {
  final int id;
  final User user;
  final bool isMe;
  final String avatarUrl;

  _Header({
    @required this.id,
    @required this.user,
    @required this.isMe,
    @required this.avatarUrl,
  });

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final shrinkPercentage = shrinkOffset / (maxExtent - minExtent);
    final avatar = avatarUrl ?? user?.avatar;

    return Container(
      height: maxExtent,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).backgroundColor,
            blurRadius: 7,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (user?.banner != null)
            FadeInImage.memoryNetwork(
              image: user.banner,
              placeholder: transparentImage,
              fadeInDuration: Config.FADE_DURATION,
              fit: BoxFit.cover,
            ),
          Container(
            padding: const EdgeInsets.only(
              top: Config.MATERIAL_TAP_TARGET_SIZE,
              left: 10,
              right: 10,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Theme.of(context).backgroundColor.withAlpha(70),
                  Theme.of(context).backgroundColor,
                ],
              ),
            ),
            child: Column(
              children: [
                if (avatar != null)
                  GestureDetector(
                    child: Hero(
                      tag: id.toString(),
                      child: ClipRRect(
                        borderRadius: Config.BORDER_RADIUS,
                        child: Container(
                          height: 150,
                          width: 150,
                          child: Image.network(avatar, fit: BoxFit.cover),
                        ),
                      ),
                    ),
                    onTap: () => showDialog(
                      context: context,
                      builder: (_) => PopUpAnimation(
                        Image.network(avatar, fit: BoxFit.cover),
                      ),
                    ),
                  ),
                const SizedBox(height: 10),
                if (user?.name != null)
                  Text(user.name, style: Theme.of(context).textTheme.headline3),
              ],
            ),
          ),
          if (shrinkOffset > 0)
            Container(
              height: double.infinity,
              width: double.infinity,
              color: Theme.of(context)
                  .backgroundColor
                  .withAlpha((shrinkPercentage * 255).round()),
            ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (isMe) ...[
                  const SizedBox(),
                  IconButton(
                    icon: const Icon(
                        FluentSystemIcons.ic_fluent_settings_regular),
                    color: Theme.of(context).dividerColor,
                    onPressed: () => Navigator.push(
                      context,
                      PageTransition.to(SettingsPage()),
                    ),
                  ),
                ] else ...[
                  IconButton(
                    icon: const Icon(Icons.close),
                    color: Theme.of(context).dividerColor,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  double get maxExtent => 300;

  @override
  double get minExtent => 0;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      true;

  @override
  PersistentHeaderShowOnScreenConfiguration get showOnScreenConfiguration =>
      null;

  @override
  FloatingHeaderSnapConfiguration get snapConfiguration => null;

  @override
  OverScrollHeaderStretchConfiguration get stretchConfiguration => null;

  @override
  TickerProvider get vsync => null;
}
