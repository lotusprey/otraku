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
import 'package:otraku/services/network.dart';
import 'package:otraku/tools/navigation/custom_drawer.dart';
import 'package:otraku/tools/navigation/custom_sliver_header.dart';
import 'package:otraku/tools/overlays/dialogs.dart';
import 'package:otraku/models/model_helpers.dart';

class UserPage extends StatelessWidget {
  final int id;
  final String avatarUrl;

  const UserPage(this.id, this.avatarUrl);

  @override
  Widget build(BuildContext context) => GetBuilder<User>(
        tag: id?.toString() ?? Network.viewerId.toString(),
        builder: (user) => CustomScrollView(
          physics: Config.PHYSICS,
          slivers: [
            _Header(
              id: id ?? Network.viewerId,
              user: user.data,
              isMe: id == null,
              avatarUrl: avatarUrl,
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

class _Header extends StatelessWidget {
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
  Widget build(BuildContext context) {
    const avatarSize = 150.0;
    final bannerHeight = MediaQuery.of(context).size.width * 0.6;
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
            icon: const Icon(FluentSystemIcons.ic_fluent_settings_regular),
            color: Theme.of(context).dividerColor,
            onPressed: () => Get.to(SettingsPage()),
          ))
        else if (user != null)
          Padding(
            padding: const EdgeInsets.only(right: 10, top: 8, bottom: 8),
            child: FlatButton(
              child: Text(
                user.following ? 'Unfollow' : 'Follow',
                style: Theme.of(context)
                    .textTheme
                    .button
                    .copyWith(fontSize: Styles.FONT_SMALL),
              ),
              color: Theme.of(context).accentColor,
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
                child: user?.banner != null
                    ? FadeInImage.memoryNetwork(
                        image: user.banner,
                        placeholder: transparentImage,
                        fadeInDuration: Config.FADE_DURATION,
                        fit: BoxFit.cover,
                        height: bannerHeight,
                        width: double.infinity,
                      )
                    : Container(color: Theme.of(context).primaryColor),
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
                      tag: id.toString(),
                      child: ClipRRect(
                        borderRadius: Config.BORDER_RADIUS,
                        child: Container(
                          height: avatarSize,
                          width: avatarSize,
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
                  )
                : SizedBox(width: avatarSize),
            const SizedBox(width: 10),
            if (user?.name != null)
              Text(
                user.name,
                style: Theme.of(context).textTheme.headline3,
              ),
          ],
        ),
      ),
    );
  }
}
