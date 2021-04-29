import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otraku/controllers/collection.dart';
import 'package:otraku/controllers/user.dart';
import 'package:otraku/pages/friends_page.dart';
import 'package:otraku/widgets/html_content.dart';
import 'package:otraku/widgets/navigation/user_header.dart';
import 'package:otraku/pages/user_feed_page.dart';
import 'package:otraku/pages/favourites_page.dart';
import 'package:otraku/pages/home/home_page.dart';
import 'package:otraku/utils/config.dart';
import 'package:otraku/pages/home/collection_page.dart';
import 'package:otraku/utils/client.dart';
import 'package:otraku/widgets/navigation/nav_bar.dart';

class UserPage extends StatelessWidget {
  static const ROUTE = '/user';

  final int id;
  final String? avatarUrl;

  const UserPage(this.id, this.avatarUrl);

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: SafeArea(child: UserTab(id, avatarUrl)));
  }
}

class UserTab extends StatelessWidget {
  final int id;
  final String? avatarUrl;

  const UserTab(this.id, this.avatarUrl);

  @override
  Widget build(BuildContext context) {
    final sidePadding = MediaQuery.of(context).size.width > 620
        ? (MediaQuery.of(context).size.width - 600) / 2.0
        : 10.0;

    final padding = EdgeInsets.only(
      left: sidePadding,
      right: sidePadding,
      top: 15,
    );

    return GetBuilder<User>(
      tag: id.toString(),
      builder: (user) => CustomScrollView(
        physics: Config.PHYSICS,
        slivers: [
          UserHeader(
            id: id,
            user: user.model,
            isMe: id == Client.viewerId,
            avatarUrl: avatarUrl,
          ),
          if (user.model != null)
            SliverPadding(
              padding: padding,
              sliver: SliverGrid.extent(
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                maxCrossAxisExtent: 300,
                childAspectRatio: 4,
                children: [
                  _Button(
                    FluentIcons.movies_and_tv_24_filled,
                    'Anime',
                    () => id == Client.viewerId
                        ? Config.setIndex(HomePage.ANIME_LIST)
                        : _pushCollection(true),
                  ),
                  _Button(
                    FluentIcons.bookmark_24_filled,
                    'Manga',
                    () => id == Client.viewerId
                        ? Config.setIndex(HomePage.MANGA_LIST)
                        : _pushCollection(false),
                  ),
                  _Button(
                    FluentIcons.people_team_20_filled,
                    'Following',
                    () => Get.toNamed(FriendsPage.ROUTE, arguments: [id, true]),
                  ),
                  _Button(
                    FluentIcons.people_audience_20_filled,
                    'Followers',
                    () =>
                        Get.toNamed(FriendsPage.ROUTE, arguments: [id, false]),
                  ),
                  _Button(
                    FluentIcons.comment_24_filled,
                    'User Feed',
                    () => Get.toNamed(UserFeedPage.ROUTE, arguments: id),
                  ),
                  _Button(
                    FluentIcons.heart_24_filled,
                    'Favourites',
                    () => Get.toNamed(FavouritesPage.ROUTE, arguments: id),
                  ),
                ],
              ),
            ),
          if (user.model?.description != null)
            SliverToBoxAdapter(
              child: Container(
                margin: padding,
                padding: Config.PADDING,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: Config.BORDER_RADIUS,
                ),
                child: HtmlContent(user.model!.description!),
              ),
            ),
          SliverToBoxAdapter(child: SizedBox(height: NavBar.offset(context))),
        ],
      ),
    );
  }

  void _pushCollection(bool ofAnime) {
    final collectionTag = '${ofAnime ? Collection.ANIME : Collection.MANGA}$id';
    Get.toNamed(
      CollectionPage.ROUTE,
      arguments: [id, ofAnime, collectionTag],
      preventDuplicates: false,
    );
  }
}

class _Button extends StatelessWidget {
  final IconData icon;
  final String title;
  final Function() onTap;

  _Button(this.icon, this.title, this.onTap);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: Config.BORDER_RADIUS,
      onTap: onTap,
      child: Row(
        children: [
          Expanded(child: Icon(icon, color: Theme.of(context).dividerColor)),
          Expanded(
            flex: 2,
            child: Text(title, style: Theme.of(context).textTheme.headline5),
          )
        ],
      ),
      splashColor: Theme.of(context).textSelectionTheme.selectionColor,
    );
  }
}
