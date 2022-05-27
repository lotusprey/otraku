import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/controllers/home_controller.dart';
import 'package:otraku/controllers/user_controller.dart';
import 'package:otraku/utils/settings.dart';
import 'package:otraku/utils/route_arg.dart';
import 'package:otraku/widgets/html_content.dart';
import 'package:otraku/widgets/navigation/user_header.dart';
import 'package:otraku/views/home_view.dart';
import 'package:otraku/constants/consts.dart';
import 'package:otraku/widgets/layouts/nav_layout.dart';

class UserView extends StatelessWidget {
  const UserView(this.id, this.avatarUrl);

  final int id;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) =>
      Scaffold(body: SafeArea(child: HomeUserView(id, avatarUrl)));
}

class HomeUserView extends StatelessWidget {
  const HomeUserView(this.id, this.avatarUrl, [this.scrollCtrl]);

  final int id;
  final String? avatarUrl;
  final ScrollController? scrollCtrl;

  @override
  Widget build(BuildContext context) {
    final sidePadding = MediaQuery.of(context).size.width > Consts.layoutBig
        ? (MediaQuery.of(context).size.width - Consts.layoutBig) / 2
        : 10.0;

    final padding = EdgeInsets.only(
      left: sidePadding,
      right: sidePadding,
      top: 10,
    );

    return SafeArea(
      child: GetBuilder<UserController>(
        init: UserController(id),
        tag: id.toString(),
        builder: (ctrl) => CustomScrollView(
          controller: scrollCtrl,
          slivers: [
            UserHeader(
              id: id,
              user: ctrl.model,
              isMe: id == Settings().id,
              avatarUrl: avatarUrl,
            ),
            if (ctrl.model != null)
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
                      () => id == Settings().id
                          ? Get.find<HomeController>().homeTab =
                              HomeView.ANIME_LIST
                          : Navigator.pushNamed(
                              context,
                              RouteArg.collection,
                              arguments: RouteArg(id: id, variant: true),
                            ),
                    ),
                    _Button(
                      Ionicons.bookmark,
                      'Manga',
                      () => id == Settings().id
                          ? Get.find<HomeController>().homeTab =
                              HomeView.MANGA_LIST
                          : Navigator.pushNamed(
                              context,
                              RouteArg.collection,
                              arguments: RouteArg(id: id, variant: false),
                            ),
                    ),
                    _Button(
                      Ionicons.people_circle,
                      'Following',
                      () => Navigator.pushNamed(
                        context,
                        RouteArg.friends,
                        arguments: RouteArg(id: id, variant: true),
                      ),
                    ),
                    _Button(
                      Ionicons.person_circle,
                      'Followers',
                      () => Navigator.pushNamed(
                        context,
                        RouteArg.friends,
                        arguments: RouteArg(id: id, variant: false),
                      ),
                    ),
                    _Button(
                      Ionicons.chatbox,
                      'Activities',
                      () => Navigator.pushNamed(
                        context,
                        RouteArg.activities,
                        arguments: RouteArg(id: id),
                      ),
                    ),
                    _Button(
                      Icons.favorite,
                      'Favourites',
                      () => Navigator.pushNamed(
                        context,
                        RouteArg.favourites,
                        arguments: RouteArg(id: id),
                      ),
                    ),
                    _Button(
                      Ionicons.stats_chart,
                      'Statistics',
                      () => Navigator.pushNamed(
                        context,
                        RouteArg.statistics,
                        arguments: RouteArg(id: id),
                      ),
                    ),
                    _Button(
                      Icons.rate_review,
                      'Reviews',
                      () => Navigator.pushNamed(
                        context,
                        RouteArg.reviews,
                        arguments: RouteArg(id: id),
                      ),
                    ),
                  ],
                ),
              ),
            if (!(ctrl.model?.description.isEmpty ?? true))
              SliverToBoxAdapter(
                child: Container(
                  margin: padding,
                  padding: Consts.padding,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: Consts.borderRadiusMin,
                  ),
                  child: HtmlContent(ctrl.model!.description),
                ),
              ),
            SliverToBoxAdapter(
                child: SizedBox(height: NavLayout.offset(context))),
          ],
        ),
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
      borderRadius: Consts.borderRadiusMin,
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
              child: Icon(icon,
                  color: Theme.of(context).colorScheme.onBackground)),
          Expanded(
            flex: 2,
            child: Text(title, style: Theme.of(context).textTheme.headline2),
          )
        ],
      ),
      splashColor: Theme.of(context).textSelectionTheme.selectionColor,
    );
  }
}
