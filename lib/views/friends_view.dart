import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/controllers/friends_controller.dart';
import 'package:otraku/utils/scrolling_controller.dart';
import 'package:otraku/widgets/layouts/tile_grid.dart';
import 'package:otraku/widgets/loaders.dart/loader.dart';
import 'package:otraku/widgets/layouts/nav_layout.dart';
import 'package:otraku/widgets/navigation/app_bars.dart';

class FriendsView extends StatelessWidget {
  FriendsView(this.id, this.onFollowing);

  final int id;
  final bool onFollowing;

  @override
  Widget build(BuildContext context) {
    final keyFollowing = UniqueKey();
    final keyFollowers = UniqueKey();

    return GetBuilder<FriendsController>(
      init: FriendsController(id, onFollowing),
      tag: id.toString(),
      builder: (ctrl) => NavLayout(
        navRow: NavIconRow(
          index: ctrl.onFollowing ? 0 : 1,
          onChanged: (page) => ctrl.onFollowing = page == 0 ? true : false,
          onSame: (_) => ctrl.scrollCtrl.scrollUpTo(0),
          items: const {
            'Following': Ionicons.people_circle,
            'Followers': Ionicons.person_circle,
          },
        ),
        appBar: ShadowAppBar(
          title: ctrl.onFollowing ? 'Following' : 'Followers',
        ),
        child: ctrl.users.isNotEmpty
            ? TileGrid(
                models: ctrl.users,
                scrollCtrl: ctrl.scrollCtrl,
                full: false,
                key: ctrl.onFollowing ? keyFollowing : keyFollowers,
              )
            : Center(
                child: ctrl.hasNextPage
                    ? const Loader()
                    : Text(
                        'No Users',
                        style: Theme.of(context).textTheme.subtitle2,
                      ),
              ),
      ),
    );
  }
}
