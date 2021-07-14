import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/controllers/collection_controller.dart';
import 'package:otraku/controllers/user_controller.dart';
import 'package:otraku/views/friends_view.dart';
import 'package:otraku/views/feed_view.dart';
import 'package:otraku/views/statistics_view.dart';
import 'package:otraku/views/user_reviews_view.dart';
import 'package:otraku/widgets/html_content.dart';
import 'package:otraku/widgets/navigation/user_header.dart';
import 'package:otraku/views/favourites_view.dart';
import 'package:otraku/views/home_view.dart';
import 'package:otraku/utils/config.dart';
import 'package:otraku/views/collection_view.dart';
import 'package:otraku/utils/client.dart';
import 'package:otraku/widgets/navigation/nav_bar.dart';

class UserView extends StatelessWidget {
  static const ROUTE = '/user';

  final int id;
  final String? avatarUrl;

  const UserView(this.id, this.avatarUrl);

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: SafeArea(child: HomeUserView(id, avatarUrl)));
  }
}

class HomeUserView extends StatelessWidget {
  final int id;
  final String? avatarUrl;

  const HomeUserView(this.id, this.avatarUrl);

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

    return GetBuilder<UserController>(
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
                maxCrossAxisExtent: 200,
                childAspectRatio: 5,
                children: [
                  _Button(
                    Ionicons.film,
                    'Anime',
                    () => id == Client.viewerId
                        ? Config.setIndex(HomeView.ANIME_LIST)
                        : _pushCollection(true),
                  ),
                  _Button(
                    Ionicons.bookmark,
                    'Manga',
                    () => id == Client.viewerId
                        ? Config.setIndex(HomeView.MANGA_LIST)
                        : _pushCollection(false),
                  ),
                  _Button(
                    Ionicons.people_circle,
                    'Following',
                    () => Get.toNamed(FriendsView.ROUTE, arguments: [id, true]),
                  ),
                  _Button(
                    Ionicons.person_circle,
                    'Followers',
                    () =>
                        Get.toNamed(FriendsView.ROUTE, arguments: [id, false]),
                  ),
                  _Button(
                    Ionicons.chatbox,
                    'User Feed',
                    () => Get.toNamed(FeedView.ROUTE, arguments: id),
                  ),
                  _Button(
                    Icons.favorite,
                    'Favourites',
                    () => Get.toNamed(FavouritesView.ROUTE, arguments: id),
                  ),
                  _Button(
                    Ionicons.stats_chart,
                    'Statistics',
                    () => Get.toNamed(StatisticsView.ROUTE, arguments: id),
                  ),
                  _Button(
                    Icons.rate_review,
                    'Reviews',
                    () => Get.toNamed(UserReviewsView.ROUTE, arguments: id),
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
    final collectionTag =
        '${ofAnime ? CollectionController.ANIME : CollectionController.MANGA}$id';
    Get.toNamed(
      CollectionView.ROUTE,
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
