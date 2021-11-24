import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/controllers/home_controller.dart';
import 'package:otraku/controllers/user_controller.dart';
import 'package:otraku/utils/navigation.dart';
import 'package:otraku/utils/local_settings.dart';
import 'package:otraku/widgets/html_content.dart';
import 'package:otraku/widgets/navigation/user_header.dart';
import 'package:otraku/views/home_view.dart';
import 'package:otraku/constants/config.dart';
import 'package:otraku/widgets/layouts/nav_layout.dart';

class UserView extends StatelessWidget {
  final int id;
  final String? avatarUrl;

  const UserView(this.id, this.avatarUrl);

  @override
  Widget build(BuildContext context) =>
      Scaffold(body: SafeArea(child: HomeUserView(id, avatarUrl)));
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
            isMe: id == LocalSettings().id,
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
                    () => id == LocalSettings().id
                        ? Get.find<HomeController>().homeTab =
                            HomeView.ANIME_LIST
                        : Navigation().push(
                            Navigation.collectionRoute,
                            args: [id, true],
                          ),
                  ),
                  _Button(
                    Ionicons.bookmark,
                    'Manga',
                    () => id == LocalSettings().id
                        ? Get.find<HomeController>().homeTab =
                            HomeView.MANGA_LIST
                        : Navigation().push(
                            Navigation.collectionRoute,
                            args: [id, false],
                          ),
                  ),
                  _Button(
                    Ionicons.people_circle,
                    'Following',
                    () => Navigation()
                        .push(Navigation.friendsRoute, args: [id, true]),
                  ),
                  _Button(
                    Ionicons.person_circle,
                    'Followers',
                    () => Navigation()
                        .push(Navigation.friendsRoute, args: [id, false]),
                  ),
                  _Button(
                    Ionicons.chatbox,
                    'User Feed',
                    () => Navigation().push(Navigation.feedRoute, args: [id]),
                  ),
                  _Button(
                    Icons.favorite,
                    'Favourites',
                    () => Navigation()
                        .push(Navigation.favouritesRoute, args: [id]),
                  ),
                  _Button(
                    Ionicons.stats_chart,
                    'Statistics',
                    () => Navigation()
                        .push(Navigation.statisticsRoute, args: [id]),
                  ),
                  _Button(
                    Icons.rate_review,
                    'Reviews',
                    () => Navigation()
                        .push(Navigation.userReviewsRoute, args: [id]),
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
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: Config.BORDER_RADIUS,
                ),
                child: HtmlContent(user.model!.description!),
              ),
            ),
          SliverToBoxAdapter(
              child: SizedBox(height: NavLayout.offset(context))),
        ],
      ),
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
          Expanded(
              child: Icon(icon,
                  color: Theme.of(context).colorScheme.onBackground)),
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
