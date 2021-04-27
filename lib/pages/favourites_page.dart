import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:otraku/controllers/favourites.dart';
import 'package:otraku/utils/config.dart';
import 'package:otraku/models/user_model.dart';
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
    return GetBuilder<Favourites>(
      tag: id.toString(),
      builder: (favourites) => Scaffold(
        extendBody: true,
        bottomNavigationBar: NavBar(
          options: {
            'Anime': FluentIcons.movies_and_tv_24_regular,
            'Manga': FluentIcons.bookmark_24_regular,
            'Characters': FluentIcons.accessibility_24_regular,
            'Staff': FluentIcons.mic_on_24_regular,
            'Studios': FluentIcons.building_24_regular,
          },
          initial: favourites.pageIndex,
          onChanged: (index) => favourites.pageIndex = index,
        ),
        appBar: CustomAppBar(title: 'Favourite ${favourites.pageName}'),
        body: SafeArea(
          bottom: false,
          child: CustomScrollView(
            controller: favourites.scrollCtrl,
            physics: Config.PHYSICS,
            slivers: [
              favourites.favourites.isNotEmpty
                  ? favourites.pageIndex == UserModel.STUDIO_FAV
                      ? TitleList(favourites.favourites)
                      : TileGrid(
                          tileData: favourites.favourites,
                          tileModel: Config.highTile,
                        )
                  : SliverFillRemaining(
                      child: Center(
                        child: Text(
                          'Nothing here',
                          style: Theme.of(context).textTheme.subtitle1,
                        ),
                      ),
                    ),
              SliverToBoxAdapter(
                child: SizedBox(height: NavBar.offset(context)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
