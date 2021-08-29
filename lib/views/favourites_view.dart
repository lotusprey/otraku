import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:otraku/controllers/favourites_controller.dart';
import 'package:otraku/enums/explorable.dart';
import 'package:otraku/models/user_model.dart';
import 'package:otraku/widgets/layouts/tile_grid.dart';
import 'package:otraku/widgets/layouts/title_list.dart';
import 'package:otraku/widgets/nav_scaffold.dart';
import 'package:otraku/widgets/navigation/app_bars.dart';
import 'package:otraku/widgets/navigation/nav_bar.dart';

class FavouritesView extends StatelessWidget {
  final int id;
  FavouritesView(this.id);

  @override
  Widget build(BuildContext context) => GetBuilder<FavouritesController>(
        tag: id.toString(),
        builder: (favourites) => NavScaffold(
          navBar: NavBar(
            items: {
              'Anime': Explorable.anime.icon,
              'Manga': Explorable.manga.icon,
              'Characters': Explorable.character.icon,
              'Staff': Explorable.staff.icon,
              'Studios': Explorable.studio.icon,
            },
            initial: favourites.pageIndex,
            onChanged: (index) => favourites.pageIndex = index,
          ),
          appBar: ShadowAppBar(title: 'Favourite ${favourites.pageName}'),
          child: favourites.favourites.isNotEmpty
              ? favourites.pageIndex == UserModel.STUDIO_FAV
                  ? TitleList(
                      favourites.favourites,
                      scrollCtrl: favourites.scrollCtrl,
                      key: favourites.key,
                    )
                  : TileGrid(
                      models: favourites.favourites,
                      scrollCtrl: favourites.scrollCtrl,
                      key: favourites.key,
                    )
              : Center(
                  child: Text(
                    'Nothing here',
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                ),
        ),
      );
}
