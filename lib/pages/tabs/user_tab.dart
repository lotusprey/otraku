import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:otraku/controllers/collection.dart';
import 'package:otraku/controllers/user.dart';
import 'package:otraku/models/user_data.dart';
import 'package:otraku/pages/pushable/settings_page.dart';
import 'package:otraku/pages/pushable/tab_page.dart';
import 'package:otraku/pages/tab_manager.dart';
import 'package:otraku/services/config.dart';
import 'package:otraku/pages/tabs/collections_tab.dart';
import 'package:otraku/services/graph_ql.dart';
import 'package:otraku/tools/custom_drawer.dart';
import 'package:otraku/tools/overlays/dialogs.dart';
import 'package:otraku/models/transparent_image.dart';

class UserTab extends StatelessWidget {
  final _space = const SizedBox(width: 10);

  final int id;
  final String avatarUrl;

  const UserTab(this.id, this.avatarUrl);

  @override
  Widget build(BuildContext context) => GetBuilder<User>(
        tag: id?.toString() ?? GraphQl.viewerId.toString(),
        builder: (user) => CustomScrollView(
          physics: Config.PHYSICS,
          slivers: [
            SliverPersistentHeader(
              delegate: _Header(
                id: id,
                user: user.data,
                isMe: id == null,
                avatarUrl: avatarUrl,
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.only(left: 10, right: 10, top: 5),
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
                            : _pushCollection(true),
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
                            : _pushCollection(false),
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
        ),
      );

  void _pushCollection(bool ofAnime) {
    final collectionTag = '${ofAnime ? Collection.ANIME : Collection.MANGA}$id';
    Get.to(
      TabPage(
        CollectionsTab(
          otherUserId: id,
          ofAnime: ofAnime,
          collectionTag: collectionTag,
          key: null,
        ),
        drawer: CollectionDrawer(collectionTag),
      ),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<Collection>(tag: collectionTag))
          Get.put(Collection(id, ofAnime), tag: collectionTag).fetch();
      }),
      preventDuplicates: false,
    );
  }
}

class _Header implements SliverPersistentHeaderDelegate {
  final int id;
  final UserData user;
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
                          child: FadeInImage.memoryNetwork(
                            placeholder: transparentImage,
                            image: avatar,
                            fit: BoxFit.contain,
                            fadeInDuration: Config.FADE_DURATION,
                          ),
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
                    onPressed: () => Get.to(SettingsPage()),
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
