import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:otraku/controllers/favourites_controller.dart';
import 'package:otraku/constants/explorable.dart';
import 'package:otraku/models/user_model.dart';
import 'package:otraku/widgets/layouts/tile_grid.dart';
import 'package:otraku/widgets/layouts/title_grid.dart';
import 'package:otraku/widgets/layouts/nav_layout.dart';
import 'package:otraku/widgets/navigation/app_bars.dart';

class FavouritesView extends StatelessWidget {
  FavouritesView(this.id);

  final int id;

  @override
  Widget build(BuildContext context) {
    final keys = [
      UniqueKey(),
      UniqueKey(),
      UniqueKey(),
      UniqueKey(),
      UniqueKey(),
    ];

    const names = ['Anime', 'Manga', 'Characters', 'Staff', 'Studios'];

    return GetBuilder<FavouritesController>(
      init: FavouritesController(id),
      tag: id.toString(),
      builder: (ctrl) => NavLayout(
        index: ctrl.pageIndex,
        onChanged: (index) => ctrl.pageIndex = index,
        onSame: (_) => ctrl.scrollUpTo(0),
        items: {
          'Anime': Explorable.anime.icon,
          'Manga': Explorable.manga.icon,
          'Characters': Explorable.character.icon,
          'Staff': Explorable.staff.icon,
          'Studios': Explorable.studio.icon,
        },
        appBar: ShadowAppBar(title: 'Favourite ${names[ctrl.pageIndex]}'),
        child: ctrl.favourites.isNotEmpty
            ? ctrl.pageIndex == UserModel.STUDIO_FAV
                ? TitleGrid(
                    ctrl.favourites,
                    scrollCtrl: ctrl.scrollCtrl,
                    key: keys[ctrl.pageIndex],
                  )
                : TileGrid(
                    models: ctrl.favourites,
                    scrollCtrl: ctrl.scrollCtrl,
                    key: keys[ctrl.pageIndex],
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
}
