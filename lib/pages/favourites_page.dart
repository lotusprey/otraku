import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:otraku/controllers/favourites.dart';
import 'package:otraku/enums/browsable.dart';
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
  Widget build(BuildContext context) => GetBuilder<Favourites>(
        tag: id.toString(),
        builder: (favourites) => Scaffold(
          extendBody: true,
          bottomNavigationBar: NavBar(
            options: {
              'Anime': Browsable.anime.icon,
              'Manga': Browsable.manga.icon,
              'Characters': Browsable.character.icon,
              'Staff': Browsable.staff.icon,
              'Studios': Browsable.studio.icon,
            },
            initial: favourites.pageIndex,
            onChanged: (index) => favourites.pageIndex = index,
          ),
          appBar: CustomAppBar(title: 'Favourite ${favourites.pageName}'),
          body: Padding(
            padding: EdgeInsets.only(bottom: NavBar.offset(context)),
            child: AnimatedSwitcher(
              duration: Config.TAB_SWITCH_DURATION,
              child: Center(
                key: favourites.key,
                child: favourites.favourites.isNotEmpty
                    ? favourites.pageIndex == UserModel.STUDIO_FAV
                        ? TitleList(favourites.favourites, sliver: false)
                        : TileGrid(
                            tileData: favourites.favourites,
                            tileModel: Config.highTile,
                            scrollCtrl: favourites.scrollCtrl,
                          )
                    : Text(
                        'Nothing here',
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
              ),
            ),
          ),
        ),
      );
}
