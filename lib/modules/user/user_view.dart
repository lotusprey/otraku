import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/modules/user/user_models.dart';
import 'package:otraku/modules/user/user_providers.dart';
import 'package:otraku/modules/user/user_header.dart';
import 'package:otraku/common/utils/options.dart';
import 'package:otraku/common/utils/route_arg.dart';
import 'package:otraku/common/widgets/html_content.dart';
import 'package:otraku/common/utils/consts.dart';
import 'package:otraku/common/widgets/layouts/constrained_view.dart';
import 'package:otraku/common/widgets/layouts/scaffolds.dart';
import 'package:otraku/common/widgets/loaders.dart/loaders.dart';
import 'package:otraku/common/widgets/overlays/dialogs.dart';

class UserView extends StatelessWidget {
  const UserView(this.id, this.avatarUrl);

  final int id;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) =>
      PageScaffold(child: UserSubView(id, avatarUrl));
}

class UserSubView extends StatelessWidget {
  const UserSubView(this.id, this.avatarUrl, [this.scrollCtrl]);

  final int id;
  final String? avatarUrl;
  final ScrollController? scrollCtrl;

  @override
  Widget build(BuildContext context) {
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

        final user = ref.watch(userProvider(id));

        final header = UserHeader(
          id: id,
          isViewer: id == Options().id,
          user: user.valueOrNull,
          imageUrl: avatarUrl ?? user.valueOrNull?.imageUrl,
        );

        return user.when(
          error: (_, __) => CustomScrollView(
            controller: scrollCtrl,
            slivers: [
              header,
              const SliverFillRemaining(
                child: Center(child: Text('Failed to load user')),
              )
            ],
          ),
          loading: () => CustomScrollView(
            controller: scrollCtrl,
            slivers: [
              header,
              const SliverFillRemaining(child: Center(child: Loader()))
            ],
          ),
          data: (data) => CustomScrollView(
            controller: scrollCtrl,
            slivers: [
              header,
              _ButtonRow(id),
              if (data.description.isNotEmpty)
                SliverToBoxAdapter(
                  child: ConstrainedView(
                    child: Card(
                      child: Padding(
                        padding: Consts.padding,
                        child: HtmlContent(data.description),
                      ),
                    ),
                  ),
                ),
              const SliverFooter(),
            ],
          ),
        );
      },
    );
  }
}

class _ButtonRow extends StatelessWidget {
  const _ButtonRow(this.id);

  final int id;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        height: 70,
        margin: const EdgeInsets.symmetric(vertical: 15),
        alignment: Alignment.center,
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          scrollDirection: Axis.horizontal,
          children: [
            if (id != Options().id) ...[
              _Button(
                label: 'Anime',
                icon: Ionicons.film,
                onTap: () => Navigator.pushNamed(
                  context,
                  RouteArg.collection,
                  arguments: RouteArg(id: id, variant: true),
                ),
              ),
              _Button(
                label: 'Manga',
                icon: Ionicons.bookmark,
                onTap: () => Navigator.pushNamed(
                  context,
                  RouteArg.collection,
                  arguments: RouteArg(id: id, variant: false),
                ),
              ),
            ],
            _Button(
              label: 'Activities',
              icon: Ionicons.chatbox,
              onTap: () => Navigator.pushNamed(
                context,
                RouteArg.activities,
                arguments: RouteArg(id: id),
              ),
            ),
            _Button(
              label: 'Social',
              icon: Ionicons.people_circle,
              onTap: () => Navigator.pushNamed(
                context,
                RouteArg.friends,
                arguments: RouteArg(id: id),
              ),
            ),
            _Button(
              label: 'Favourites',
              icon: Icons.favorite,
              onTap: () => Navigator.pushNamed(
                context,
                RouteArg.favourites,
                arguments: RouteArg(id: id),
              ),
            ),
            _Button(
              label: 'Statistics',
              icon: Ionicons.stats_chart,
              onTap: () => Navigator.pushNamed(
                context,
                RouteArg.statistics,
                arguments: RouteArg(id: id),
              ),
            ),
            _Button(
              label: 'Reviews',
              icon: Icons.rate_review,
              onTap: () => Navigator.pushNamed(
                context,
                RouteArg.reviews,
                arguments: RouteArg(id: id),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Button extends StatelessWidget {
  const _Button({required this.label, required this.icon, required this.onTap});

  final String label;
  final IconData icon;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: Consts.borderRadiusMax,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.onBackground),
            const SizedBox(height: 5),
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
