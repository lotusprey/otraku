import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/controllers/friends_controller.dart';
import 'package:otraku/widgets/layouts/tile_grid.dart';
import 'package:otraku/widgets/loaders.dart/loader.dart';
import 'package:otraku/widgets/nav_scaffold.dart';
import 'package:otraku/widgets/navigation/app_bars.dart';
import 'package:otraku/widgets/navigation/nav_bar.dart';

class FriendsView extends StatelessWidget {
  final int id;
  FriendsView(this.id);

  @override
  Widget build(BuildContext context) => GetBuilder<FriendsController>(
        tag: id.toString(),
        builder: (friends) => NavScaffold(
          appBar: ShadowAppBar(
            title: friends.onFollowing ? 'Following' : 'Followers',
          ),
          navBar: NavBar(
            items: {
              'Following': Ionicons.people_circle,
              'Followers': Ionicons.person_circle,
            },
            onChanged: (page) => friends.onFollowing = page == 0 ? true : false,
            initial: friends.onFollowing ? 0 : 1,
          ),
          child: friends.users.isNotEmpty
              ? TileGrid(
                  models: friends.users,
                  scrollCtrl: friends.scrollCtrl,
                  full: false,
                  key: friends.key,
                )
              : Center(
                  child: friends.hasNextPage
                      ? const Loader()
                      : Text(
                          'No Users',
                          style: Theme.of(context).textTheme.subtitle2,
                        ),
                ),
        ),
      );
}
