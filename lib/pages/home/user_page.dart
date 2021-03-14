import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:get/get.dart';
import 'package:otraku/controllers/collection.dart';
import 'package:otraku/controllers/user.dart';
import 'package:otraku/widgets/navigation/user_header.dart';
import 'package:otraku/pages/pushable/user_activities_page.dart';
import 'package:otraku/pages/pushable/favourites_page.dart';
import 'package:otraku/pages/home/home_page.dart';
import 'package:otraku/utils/config.dart';
import 'package:otraku/pages/home/collection_page.dart';
import 'package:otraku/utils/client.dart';
import 'package:otraku/widgets/navigation/nav_bar.dart';

class UserPage extends StatelessWidget {
  static const ROUTE = '/user';

  final int? id;
  final String? avatarUrl;

  const UserPage(this.id, this.avatarUrl);

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: SafeArea(child: UserTab(id, avatarUrl)));
  }
}

class UserTab extends StatelessWidget {
  final int? id;
  final String? avatarUrl;

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
                            FluentIcons.comment_24_filled,
                            color: Theme.of(context).accentColor,
                          ),
                          onPressed: () => Get.toNamed(
                            UserActivitiesPage.ROUTE,
                            arguments: id,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            FluentIcons.movies_and_tv_24_filled,
                            color: Theme.of(context).accentColor,
                          ),
                          onPressed: () => id == null
                              ? Config.setIndex(HomePage.ANIME_LIST)
                              : _pushCollection(true),
                        ),
                        IconButton(
                          icon: Icon(
                            FluentIcons.bookmark_24_filled,
                            color: Theme.of(context).accentColor,
                          ),
                          onPressed: () => id == null
                              ? Config.setIndex(HomePage.MANGA_LIST)
                              : _pushCollection(false),
                        ),
                        IconButton(
                          icon: Icon(
                            FluentIcons.heart_24_filled,
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
                        user.model!.description!,
                        textStyle: TextStyle(
                          color: Theme.of(context).textTheme.bodyText1!.color,
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
      CollectionPage.ROUTE,
      arguments: [id, ofAnime, collectionTag],
      preventDuplicates: false,
    );
  }
}
