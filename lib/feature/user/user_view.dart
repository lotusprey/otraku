import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/feature/viewer/persistence_provider.dart';
import 'package:otraku/util/routes.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/extension/snack_bar_extension.dart';
import 'package:otraku/widget/layout/adaptive_scaffold.dart';
import 'package:otraku/widget/shadowed_overflow_list.dart';
import 'package:otraku/feature/user/user_model.dart';
import 'package:otraku/feature/user/user_providers.dart';
import 'package:otraku/feature/user/user_header.dart';
import 'package:otraku/widget/html_content.dart';
import 'package:otraku/widget/layout/constrained_view.dart';
import 'package:otraku/widget/loaders.dart';

class UserView extends StatelessWidget {
  const UserView(this.tag, this.avatarUrl);

  final UserTag tag;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) => AdaptiveScaffold(child: _UserView(tag, avatarUrl));
}

/// The home page has app bars,
/// but the one on the user tab should be transparent
/// and the padding should be removed.
class UserHomeView extends StatelessWidget {
  const UserHomeView(
    this.tag,
    this.avatarUrl, {
    this.homeScrollCtrl,
    required this.removableTopPadding,
  });

  final UserTag? tag;
  final String? avatarUrl;
  final ScrollController? homeScrollCtrl;
  final double removableTopPadding;

  @override
  Widget build(BuildContext context) {
    final body = tag != null
        ? _UserView(tag!, avatarUrl, homeScrollCtrl)
        : CustomScrollView(
            controller: homeScrollCtrl,
            physics: Theming.bouncyPhysics,
            slivers: [
              UserHeader(
                id: null,
                user: null,
                isViewer: true,
                imageUrl: null,
                toggleFollow: () async => null,
              ),
              const SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: Theming.paddingAll,
                    child: Text(
                      'Log in with the profile icon at the top to view your account',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              const SliverFooter(),
            ],
          );

    final mediaQuery = MediaQuery.of(context);
    return MediaQuery(
      data: mediaQuery.copyWith(
        padding: mediaQuery.padding.copyWith(
          top: mediaQuery.padding.top - removableTopPadding,
        ),
      ),
      child: body,
    );
  }
}

class _UserView extends StatelessWidget {
  const _UserView(this.tag, this.avatarUrl, [this.scrollCtrl]);

  final UserTag tag;
  final String? avatarUrl;
  final ScrollController? scrollCtrl;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final viewer = ref.watch(
          persistenceProvider.select((s) => s.accountGroup.account),
        );

        final isViewer =
            viewer != null && (tag.id != null ? tag.id == viewer.id : tag.name == viewer.name);

        ref.listen<AsyncValue<User>>(
          userProvider(tag),
          (_, s) => s.whenOrNull(
            data: (data) {
              if (!isViewer) return;

              ref.read(persistenceProvider.notifier).refreshViewerDetails(data.name, data.imageUrl);
            },
            error: (error, _) => SnackBarExtension.show(
              context,
              error.toString(),
            ),
          ),
        );

        final user = ref.watch(userProvider(tag));

        final header = UserHeader(
          id: tag.id,
          user: user.value,
          isViewer: isViewer,
          imageUrl: avatarUrl ?? user.value?.imageUrl,
          toggleFollow: () {
            final userId = user.value?.id;
            if (userId == null) return Future.value(false);

            return ref.read(userProvider(tag).notifier).toggleFollow(userId);
          },
        );

        final mediaQuery = MediaQuery.of(context);

        final refreshControl = MediaQuery(
          data: mediaQuery.copyWith(
            padding: mediaQuery.padding.copyWith(top: 0),
          ),
          child: SliverRefreshControl(
            onRefresh: () => ref.invalidate(userProvider(tag)),
          ),
        );

        return user.unwrapPrevious().when(
              error: (_, __) => CustomScrollView(
                physics: Theming.bouncyPhysics,
                slivers: [
                  header,
                  refreshControl,
                  const SliverFillRemaining(
                    child: Center(child: Text('Failed to load user')),
                  )
                ],
              ),
              loading: () => CustomScrollView(
                slivers: [header, const SliverFillRemaining(child: Center(child: Loader()))],
              ),
              data: (data) => CustomScrollView(
                controller: scrollCtrl,
                physics: Theming.bouncyPhysics,
                slivers: [
                  header,
                  refreshControl,
                  _ButtonRow(data.id, isViewer),
                  if (data.description.isNotEmpty) ...[
                    const SliverToBoxAdapter(
                      child: SizedBox(height: Theming.offset),
                    ),
                    SliverConstrainedView(
                      sliver: HtmlContent(
                        data.description,
                        renderMode: RenderMode.sliverList,
                      ),
                    ),
                  ],
                  const SliverFooter(),
                ],
              ),
            );
      },
    );
  }
}

class _ButtonRow extends StatelessWidget {
  const _ButtonRow(this.userId, this.isViewer);

  final int userId;
  final bool isViewer;

  @override
  Widget build(BuildContext context) {
    final buttons = [
      if (!isViewer) ...[
        _Button(
          label: 'Anime',
          icon: Ionicons.film,
          onTap: () => context.push(Routes.animeCollection(userId)),
        ),
        _Button(
          label: 'Manga',
          icon: Ionicons.book,
          onTap: () => context.push(Routes.mangaCollection(userId)),
        ),
      ],
      _Button(
        label: 'Activities',
        icon: Ionicons.chatbox,
        onTap: () => context.push(Routes.activities(userId)),
      ),
      _Button(
        label: 'Social',
        icon: Ionicons.people_circle,
        onTap: () => context.push(Routes.social(userId)),
      ),
      _Button(
        label: 'Favourites',
        icon: Icons.favorite,
        onTap: () => context.push(Routes.favorites(userId)),
      ),
      _Button(
        label: 'Statistics',
        icon: Ionicons.stats_chart,
        onTap: () => context.push(Routes.statistics(userId)),
      ),
      _Button(
        label: 'Reviews',
        icon: Icons.rate_review,
        onTap: () => context.push(Routes.reviews(userId)),
      ),
    ];

    return SliverToBoxAdapter(
      child: ConstrainedView(
        child: Container(
          height: 60,
          margin: const EdgeInsets.symmetric(vertical: Theming.offset),
          alignment: Alignment.center,
          child: ShadowedOverflowList(
            itemCount: buttons.length,
            itemBuilder: (context, i) => buttons[i],
            shrinkWrap: true,
          ),
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
    return FilledButton.tonal(
      onPressed: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [Icon(icon), Text(label)],
      ),
    );
  }
}
