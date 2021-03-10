import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:otraku/controllers/user.dart';
import 'package:otraku/utils/config.dart';
import 'package:otraku/utils/client.dart';
import 'package:otraku/models/anilist/user_model.dart';
import 'package:otraku/widgets/layouts/tile_grid.dart';
import 'package:otraku/widgets/layouts/title_list.dart';
import 'package:otraku/widgets/navigation/custom_app_bar.dart';
import 'package:otraku/widgets/navigation/nav_bar.dart';

class FavouritesPage extends StatelessWidget {
  static const ROUTE = '/favourites';

  final int id;
  FavouritesPage(this.id);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<User>(
      tag: id?.toString() ?? Client.viewerId.toString(),
      builder: (user) => Scaffold(
        extendBody: true,
        bottomNavigationBar: NavBar(
          options: {
            FluentSystemIcons.ic_fluent_movies_and_tv_regular: 'Anime',
            FluentSystemIcons.ic_fluent_bookmark_regular: 'Manga',
            FluentSystemIcons.ic_fluent_accessibility_regular: 'Characters',
            FluentSystemIcons.ic_fluent_mic_on_regular: 'Staff',
            FluentSystemIcons.ic_fluent_building_regular: 'Studios',
          },
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
                user.favsIndex == UserModel.STUDIO_FAV
                    ? TitleList(user.favourites, user.fetchFavourites)
                    : TileGrid(
                        tileData: user.favourites,
                        loadMore: user.fetchFavourites,
                        tileModel: Config.highTile,
                      )
              else
                SliverFillRemaining(
                  child: Center(
                    child: Text('Nothing here',
                        style: Theme.of(context).textTheme.subtitle1),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 60)),
            ],
          ),
        ),
      ),
    );
  }
}
