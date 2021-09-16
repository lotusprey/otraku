import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/controllers/friends_controller.dart';
import 'package:otraku/widgets/layouts/tile_grid.dart';
import 'package:otraku/widgets/loaders.dart/loader.dart';
import 'package:otraku/widgets/nav_scaffold.dart';
import 'package:otraku/widgets/navigation/app_bars.dart';

class FriendsView extends StatelessWidget {
  final int id;
  FriendsView(this.id);

  @override
  Widget build(BuildContext context) => GetBuilder<FriendsController>(
        tag: id.toString(),
        builder: (ctrl) => NavScaffold(
          setPage: (page) => ctrl.onFollowing = page == 0 ? true : false,
          index: ctrl.onFollowing ? 0 : 1,
          appBar: ShadowAppBar(
            title: ctrl.onFollowing ? 'Following' : 'Followers',
          ),
          items: const {
            'Following': Ionicons.people_circle,
            'Followers': Ionicons.person_circle,
          },
          child: ctrl.users.isNotEmpty
              ? TileGrid(
                  models: ctrl.users,
                  scrollCtrl: ctrl.scrollCtrl,
                  full: false,
                  key: ctrl.key,
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
