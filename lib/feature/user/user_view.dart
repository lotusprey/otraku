import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/extension/build_context_extension.dart';
import 'package:otraku/extension/card_extension.dart';
import 'package:otraku/feature/viewer/persistence_provider.dart';
import 'package:otraku/util/routes.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/extension/snack_bar_extension.dart';
import 'package:otraku/widget/layout/adaptive_scaffold.dart';
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
                      textAlign: .center,
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
        padding: mediaQuery.padding.copyWith(top: mediaQuery.padding.top - removableTopPadding),
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
        final persistence = ref.watch(persistenceProvider);
        final highContrast = persistence.options.highContrast;
        final viewer = persistence.accountGroup.account;

        final isViewer =
            viewer != null && (tag.id != null ? tag.id == viewer.id : tag.name == viewer.name);

        ref.listen<AsyncValue<User>>(
          userProvider(tag),
          (_, s) => s.whenOrNull(
            data: (data) {
              if (!isViewer) return;

              ref.read(persistenceProvider.notifier).refreshViewerDetails(data.name, data.imageUrl);
            },
            error: (error, _) => SnackBarExtension.show(context, error.toString()),
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
          data: mediaQuery.copyWith(padding: mediaQuery.padding.copyWith(top: 0)),
          child: SliverRefreshControl(onRefresh: () => ref.invalidate(userProvider(tag))),
        );

        return user.unwrapPrevious().when(
          error: (_, _) => CustomScrollView(
            physics: Theming.bouncyPhysics,
            slivers: [
              header,
              refreshControl,
              const SliverFillRemaining(child: Center(child: Text('Failed to load user'))),
            ],
          ),
          loading: () => CustomScrollView(
            slivers: [
              header,
              const SliverFillRemaining(child: Center(child: Loader())),
            ],
          ),
          data: (data) => CustomScrollView(
            controller: scrollCtrl,
            physics: Theming.bouncyPhysics,
            slivers: [
              header,
              refreshControl,
              _ButtonRow(data.id, isViewer, highContrast),
              if (data.description.isNotEmpty) ...[
                const SliverToBoxAdapter(child: SizedBox(height: Theming.offset)),
                SliverConstrainedView(
                  sliver: HtmlContent(data.description, renderMode: RenderMode.sliverList),
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
  const _ButtonRow(this.userId, this.isViewer, this.highContrast);

  final int userId;
  final bool isViewer;
  final bool highContrast;

  @override
  Widget build(BuildContext context) {
    final buttonHeight =
        Theming.iconBig +
        context.lineHeight(TextTheme.of(context).bodyMedium!) +
        Theming.offset * 2.5;

    final buttons = [
      _Button(
        label: 'Anime',
        icon: Ionicons.film,
        highContrast: highContrast,
        onTap: () => isViewer
            ? context.go(Routes.home(.anime))
            : context.push(Routes.animeCollection(userId)),
      ),
      _Button(
        label: 'Manga',
        icon: Ionicons.book,
        highContrast: highContrast,
        onTap: () => isViewer
            ? context.go(Routes.home(.manga))
            : context.push(Routes.mangaCollection(userId)),
      ),
      _Button(
        label: 'Activities',
        icon: Ionicons.chatbox,
        highContrast: highContrast,
        onTap: () => context.push(Routes.activities(userId)),
      ),
      _Button(
        label: 'Social',
        icon: Ionicons.people_circle,
        highContrast: highContrast,
        onTap: () => context.push(Routes.social(userId)),
      ),
      _Button(
        label: 'Favourites',
        icon: Icons.favorite,
        highContrast: highContrast,
        onTap: () => context.push(Routes.favorites(userId)),
      ),
      _Button(
        label: 'Statistics',
        icon: Ionicons.stats_chart,
        highContrast: highContrast,
        onTap: () => context.push(Routes.statistics(userId)),
      ),
      _Button(
        label: 'Reviews',
        icon: Icons.rate_review,
        highContrast: highContrast,
        onTap: () => context.push(Routes.reviews(userId)),
      ),
    ];

    return SliverPadding(
      padding: const .symmetric(horizontal: Theming.offset, vertical: Theming.offset),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: Theming.offset,
          crossAxisSpacing: Theming.offset,
          mainAxisExtent: buttonHeight,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, i) => buttons[i],
          childCount: buttons.length,
        ),
      ),
    );
  }
}

class _Button extends StatelessWidget {
  const _Button({
    required this.label,
    required this.icon,
    required this.highContrast,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool highContrast;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return CardExtension.highContrast(highContrast)(
      child: InkWell(
        onTap: onTap,
        borderRadius: Theming.borderRadiusSmall,
        child: Padding(
          padding: Theming.paddingAll,
          child: Column(mainAxisAlignment: .spaceBetween, children: [Icon(icon), Text(label)]),
        ),
      ),
    );
  }
}
