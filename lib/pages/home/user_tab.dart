import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:get/get.dart';
import 'package:otraku/controllers/collection.dart';
import 'package:otraku/controllers/user.dart';
import 'package:otraku/pages/home/user_header.dart';
import 'package:otraku/pages/pushable/user_activities_page.dart';
import 'package:otraku/pages/pushable/favourites_page.dart';
import 'package:otraku/pages/home/home_page.dart';
import 'package:otraku/controllers/config.dart';
import 'package:otraku/pages/home/collection_tab.dart';
import 'package:otraku/helpers/client.dart';
import 'package:otraku/tools/navigation/nav_bar.dart';

class UserTab extends StatelessWidget {
  static const ROUTE = '/user';

  final int id;
  final String avatarUrl;

  const UserTab(this.id, this.avatarUrl);

  @override
  Widget build(BuildContext context) {
    final sidePadding = MediaQuery.of(context).size.width > 620
        ? (MediaQuery.of(context).size.width - 600) / 2.0
        : 10.0;

    return GetBuilder<User>(
      tag: id?.toString() ?? Client.viewerId.toString(),
      builder: (user) => CustomScrollView(
        physics: Config.PHYSICS,
        slivers: [
          UserHeader(
            id: id ?? Client.viewerId,
            user: user.model,
            isMe: id == null,
            avatarUrl: avatarUrl,
          ),
          SliverPadding(
            padding: EdgeInsets.only(
              left: sidePadding,
              right: sidePadding,
              top: 15,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate.fixed(
                [
                  Container(
                    height: Config.MATERIAL_TAP_TARGET_SIZE,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: Config.BORDER_RADIUS,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          icon: Icon(
                            FluentSystemIcons.ic_fluent_comment_filled,
                            color: Theme.of(context).accentColor,
                          ),
                          onPressed: () => Get.toNamed(
                            UserActivitiesPage.ROUTE,
                            arguments: id,
                          ),
                        ),
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
                          onPressed: () => Get.toNamed(
                            FavouritesPage.ROUTE,
                            arguments: id,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (user.model?.description != null)
                    Container(
                      padding: Config.PADDING,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: Config.BORDER_RADIUS,
                      ),
                      child: HtmlWidget(
                        user.model.description,
                        textStyle: TextStyle(
                          color: Theme.of(context).textTheme.bodyText1.color,
                        ),
                      ),
                    ),
                  SizedBox(height: NavBar.offset(context)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _pushCollection(bool ofAnime) {
    final collectionTag = '${ofAnime ? Collection.ANIME : Collection.MANGA}$id';
    Get.toNamed(
      CollectionTab.ROUTE,
      arguments: [id, ofAnime, collectionTag],
      preventDuplicates: false,
    );
  }
}
