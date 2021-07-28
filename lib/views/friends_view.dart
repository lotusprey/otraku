import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/controllers/friends_controller.dart';
import 'package:otraku/utils/config.dart';
import 'package:otraku/widgets/layouts/tile_grid.dart';
import 'package:otraku/widgets/loaders.dart/loader.dart';
import 'package:otraku/widgets/navigation/shadow_app_bar.dart';
import 'package:otraku/widgets/navigation/nav_bar.dart';

class FriendsView extends StatelessWidget {
  final int id;
  FriendsView(this.id);

  @override
  Widget build(BuildContext context) => GetBuilder<FriendsController>(
        tag: id.toString(),
        builder: (friends) => Scaffold(
          extendBody: true,
          appBar: ShadowAppBar(
            title: friends.onFollowing ? 'Following' : 'Followers',
          ),
          bottomNavigationBar: NavBar(
            options: {
              'Following': Ionicons.people_circle,
              'Followers': Ionicons.person_circle,
            },
            onChanged: (page) => friends.onFollowing = page == 0 ? true : false,
            initial: friends.onFollowing ? 0 : 1,
          ),
          body: AnimatedSwitcher(
            duration: Config.TAB_SWITCH_DURATION,
            child: Center(
              key: friends.key,
              child: friends.users.isNotEmpty
                  ? TileGrid(
                      models: friends.users,
                      scrollCtrl: friends.scrollCtrl,
                      full: false,
                    )
                  : friends.hasNextPage
                      ? const Center(child: Loader())
                      : Text(
                          'No Users',
                          style: Theme.of(context).textTheme.subtitle2,
                        ),
            ),
          ),
        ),
      );
}
