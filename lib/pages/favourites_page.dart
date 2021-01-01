import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:otraku/controllers/user.dart';
import 'package:otraku/controllers/config.dart';
import 'package:otraku/services/graph_ql.dart';
import 'package:otraku/tools/layouts/result_grids.dart';
import 'package:otraku/tools/navigators/custom_app_bar.dart';
import 'package:otraku/tools/navigators/custom_nav_bar.dart';

class FavouritesPage extends StatelessWidget {
  final int id;

  FavouritesPage(this.id);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<User>(
      tag: id?.toString() ?? GraphQl.viewerId.toString(),
      builder: (user) => Scaffold(
        extendBody: true,
        bottomNavigationBar: CustomNavBar(
          icons: [
            FluentSystemIcons.ic_fluent_movies_and_tv_regular,
            FluentSystemIcons.ic_fluent_bookmark_regular,
            FluentSystemIcons.ic_fluent_accessibility_regular,
            FluentSystemIcons.ic_fluent_mic_on_regular,
            FluentSystemIcons.ic_fluent_building_regular,
          ],
          initial: user.favsIndex,
          onChanged: (index) => user.favsIndex = index,
        ),
        appBar: CustomAppBar(title: 'Favourite ${user.favPageName}'),
        body: SafeArea(
          bottom: false,
          child: CustomScrollView(
            physics: Config.PHYSICS,
            slivers: [
              if (user.favourites.isNotEmpty)
                user.favsIndex == User.STUDIO_FAV
                    ? TitleList(user.favourites, user.fetchFavourites)
                    : TileGrid(
                        results: user.favourites,
                        loadMore: user.fetchFavourites,
                        tile: Config.highTile,
                      )
              else
                SliverFillRemaining(
                  child: Center(
                    child: Text('Nothing here',
                        style: Theme.of(context).textTheme.subtitle1),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
