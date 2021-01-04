import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:otraku/controllers/collection.dart';
import 'package:otraku/controllers/user.dart';
import 'package:otraku/enums/themes.dart';
import 'package:otraku/models/anilist/user_data.dart';
import 'package:otraku/pages/pushable/favourites_page.dart';
import 'package:otraku/pages/pushable/settings_page.dart';
import 'package:otraku/pages/pushable/tab_page.dart';
import 'package:otraku/pages/home_page.dart';
import 'package:otraku/controllers/config.dart';
import 'package:otraku/pages/home_pages/collection_page.dart';
import 'package:otraku/services/graph_ql.dart';
import 'package:otraku/tools/custom_drawer.dart';
import 'package:otraku/tools/overlays/dialogs.dart';
import 'package:otraku/models/transparent_image.dart';

class UserPage extends StatelessWidget {
  final int id;
  final String avatarUrl;

  const UserPage(this.id, this.avatarUrl);

  @override
  Widget build(BuildContext context) => GetBuilder<User>(
        tag: id?.toString() ?? GraphQl.viewerId.toString(),
        builder: (user) => CustomScrollView(
          physics: Config.PHYSICS,
          slivers: [
            SliverPersistentHeader(
              pinned: true,
              delegate: _Header(
                id: id ?? GraphQl.viewerId,
                user: user.data,
                isMe: id == null,
                avatarUrl: avatarUrl,
                width: MediaQuery.of(context).size.width,
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.only(left: 10, right: 10, top: 5),
              sliver: SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Container(
                    height: Config.MATERIAL_TAP_TARGET_SIZE,
                    width: MediaQuery.of(context).size.width - 20,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: Config.BORDER_RADIUS,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          icon: Icon(
                            FluentSystemIcons.ic_fluent_movies_and_tv_filled,
                            color: Theme.of(context).accentColor,
                          ),
                          onPressed: () => id == null
                              ? Get.find<Config>().pageIndex =
                                  HomePage.ANIME_LIST
                              : _pushCollection(true),
                        ),
                        IconButton(
                          icon: Icon(
                            FluentSystemIcons.ic_fluent_bookmark_filled,
                            color: Theme.of(context).accentColor,
                          ),
                          onPressed: () => id == null
                              ? Get.find<Config>().pageIndex =
                                  HomePage.MANGA_LIST
                              : _pushCollection(false),
                        ),
                        IconButton(
                          icon: Icon(
                            FluentSystemIcons.ic_fluent_heart_filled,
                            color: Theme.of(context).accentColor,
                          ),
                          onPressed: () => Get.to(FavouritesPage(id)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: const SizedBox(height: 1000),
            ),
          ],
        ),
      );

  void _pushCollection(bool ofAnime) {
    final collectionTag = '${ofAnime ? Collection.ANIME : Collection.MANGA}$id';
    Get.to(
      TabPage(
        CollectionPage(
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
  double _height;

  _Header({
    @required this.id,
    @required this.user,
    @required this.isMe,
    @required this.avatarUrl,
    @required width,
  }) {
    _height = width * 0.6 + 100;
    if (_height < 200) _height = 200;
  }

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final shrinkPercentage =
        shrinkOffset < _height ? shrinkOffset / _height : 1.0;
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
            Align(
              alignment: Alignment.topCenter,
              child: FadeInImage.memoryNetwork(
                image: user.banner,
                placeholder: transparentImage,
                fadeInDuration: Config.FADE_DURATION,
                fit: BoxFit.cover,
                height: _height - 100,
                width: double.infinity,
              ),
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
                stops: [0, (_height - 100) / _height],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  flex: 8,
                  child: GestureDetector(
                    child: avatar != null
                        ? Hero(
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
                          )
                        : null,
                    onTap: () => showDialog(
                      context: context,
                      builder: (_) => PopUpAnimation(
                        Image.network(avatar, fit: BoxFit.cover),
                      ),
                    ),
                  ),
                ),
                Flexible(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      user?.name ?? '',
                      style: Theme.of(context).textTheme.headline3,
                    ),
                  ),
                ),
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
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: user != null
                        ? FlatButton(
                            child: Text(
                              user.following ? 'Unfollow' : 'Follow',
                              style: Theme.of(context)
                                  .textTheme
                                  .button
                                  .copyWith(fontSize: Styles.FONT_SMALL),
                            ),
                            color: Theme.of(context).accentColor,
                            onPressed:
                                Get.find<User>(tag: id.toString()).toggleFollow,
                            visualDensity: VisualDensity.compact,
                          )
                        : null,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  double get maxExtent => _height;

  @override
  double get minExtent => Config.MATERIAL_TAP_TARGET_SIZE;

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
