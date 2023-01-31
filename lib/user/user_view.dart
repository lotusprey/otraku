import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/home/home_provider.dart';
import 'package:otraku/user/user_models.dart';
import 'package:otraku/user/user_providers.dart';
import 'package:otraku/user/user_header.dart';
import 'package:otraku/utils/options.dart';
import 'package:otraku/utils/route_arg.dart';
import 'package:otraku/widgets/grids/sliver_grid_delegates.dart';
import 'package:otraku/widgets/html_content.dart';
import 'package:otraku/home/home_view.dart';
import 'package:otraku/utils/consts.dart';
import 'package:otraku/widgets/layouts/page_layout.dart';
import 'package:otraku/widgets/loaders.dart/loaders.dart';
import 'package:otraku/widgets/overlays/dialogs.dart';

class UserView extends StatelessWidget {
  const UserView(this.id, this.avatarUrl);

  final int id;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) =>
      PageLayout(child: UserSubView(id, avatarUrl));
}

class UserSubView extends StatelessWidget {
  const UserSubView(this.id, this.avatarUrl, [this.scrollCtrl]);

  final int id;
  final String? avatarUrl;
  final ScrollController? scrollCtrl;

  @override
  Widget build(BuildContext context) {
    final sidePadding = MediaQuery.of(context).size.width > Consts.layoutBig
        ? (MediaQuery.of(context).size.width - Consts.layoutBig) / 2
        : 10.0;

    final padding = EdgeInsets.only(
      left: sidePadding,
      right: sidePadding,
      top: 10,
    );

    return Consumer(
      builder: (context, ref, _) {
        ref.listen<AsyncValue<User>>(
          userProvider(id),
          (_, s) => s.whenOrNull(
            error: (error, _) => showPopUp(
              context,
              ConfirmationDialog(
                title: 'Failed to load user',
                content: error.toString(),
              ),
            ),
          ),
        );

        final items = <Widget>[];
        ref.watch(userProvider(id)).when(
          error: (_, __) {
            items.add(UserHeader(
              id: id,
              user: null,
              isMe: id == Options().id,
              imageUrl: avatarUrl,
            ));
            items.add(
              const SliverFillRemaining(
                child: Center(child: Text('Failed to load user')),
              ),
            );
          },
          loading: () {
            items.add(UserHeader(
              id: id,
              user: null,
              isMe: id == Options().id,
              imageUrl: avatarUrl,
            ));
            items.add(
              const SliverFillRemaining(child: Center(child: Loader())),
            );
          },
          data: (data) {
            items.add(UserHeader(
              id: id,
              user: data,
              isMe: id == Options().id,
              imageUrl: avatarUrl,
            ));

            items.add(SliverPadding(
              padding: padding,
              sliver: SliverGrid(
                gridDelegate:
                    const SliverGridDelegateWithMinWidthAndFixedHeight(
                  minWidth: 160,
                  height: 40,
                ),
                delegate: SliverChildListDelegate.fixed(
                  [
                    _Button(
                      Ionicons.film,
                      'Anime',
                      () => id == Options().id
                          ? ref.read(homeProvider).homeTab = HomeView.ANIME_LIST
                          : Navigator.pushNamed(
                              context,
                              RouteArg.collection,
                              arguments: RouteArg(id: id, variant: true),
                            ),
                    ),
                    _Button(
                      Ionicons.bookmark,
                      'Manga',
                      () => id == Options().id
                          ? ref.read(homeProvider).homeTab = HomeView.MANGA_LIST
                          : Navigator.pushNamed(
                              context,
                              RouteArg.collection,
                              arguments: RouteArg(id: id, variant: false),
                            ),
                    ),
                    _Button(
                      Ionicons.people_circle,
                      'Following',
                      () => Navigator.pushNamed(
                        context,
                        RouteArg.friends,
                        arguments: RouteArg(id: id, variant: true),
                      ),
                    ),
                    _Button(
                      Ionicons.person_circle,
                      'Followers',
                      () => Navigator.pushNamed(
                        context,
                        RouteArg.friends,
                        arguments: RouteArg(id: id, variant: false),
                      ),
                    ),
                    _Button(
                      Ionicons.chatbox,
                      'Activities',
                      () => Navigator.pushNamed(
                        context,
                        RouteArg.activities,
                        arguments: RouteArg(id: id),
                      ),
                    ),
                    _Button(
                      Icons.favorite,
                      'Favourites',
                      () => Navigator.pushNamed(
                        context,
                        RouteArg.favourites,
                        arguments: RouteArg(id: id),
                      ),
                    ),
                    _Button(
                      Ionicons.stats_chart,
                      'Statistics',
                      () => Navigator.pushNamed(
                        context,
                        RouteArg.statistics,
                        arguments: RouteArg(id: id),
                      ),
                    ),
                    _Button(
                      Icons.rate_review,
                      'Reviews',
                      () => Navigator.pushNamed(
                        context,
                        RouteArg.reviews,
                        arguments: RouteArg(id: id),
                      ),
                    ),
                  ],
                ),
              ),
            ));

            if (data.description.isNotEmpty) {
              items.add(SliverToBoxAdapter(
                child: Card(
                  margin: padding,
                  child: Padding(
                    padding: Consts.padding,
                    child: HtmlContent(data.description),
                  ),
                ),
              ));
            }
          },
        );
        items.add(const SliverFooter());

        return SafeArea(
          child: CustomScrollView(controller: scrollCtrl, slivers: items),
        );
      },
    );
  }
}

class _Button extends StatelessWidget {
  const _Button(this.icon, this.title, this.onTap);

  final IconData icon;
  final String title;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.onBackground,
      ),
      child: Row(
        children: [
          Expanded(child: Icon(icon)),
          Expanded(
            flex: 2,
            child: Text(title, style: Theme.of(context).textTheme.titleMedium),
          ),
        ],
      ),
    );
  }
}
