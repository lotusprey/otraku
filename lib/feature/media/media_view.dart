import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/extension/scroll_controller_extension.dart';
import 'package:otraku/extension/snack_bar_extension.dart';
import 'package:otraku/feature/activity/activities_model.dart';
import 'package:otraku/feature/activity/activities_provider.dart';
import 'package:otraku/feature/media/media_activities_view.dart';
import 'package:otraku/feature/media/media_floating_actions.dart';
import 'package:otraku/feature/media/media_characters_view.dart';
import 'package:otraku/feature/media/media_following_view.dart';
import 'package:otraku/feature/media/media_models.dart';
import 'package:otraku/feature/media/media_provider.dart';
import 'package:otraku/feature/media/media_recommendations_view.dart';
import 'package:otraku/feature/media/media_related_view.dart';
import 'package:otraku/feature/media/media_reviews_view.dart';
import 'package:otraku/feature/media/media_staff_view.dart';
import 'package:otraku/feature/media/media_stats_view.dart';
import 'package:otraku/feature/media/media_threads_view.dart';
import 'package:otraku/feature/viewer/persistence_provider.dart';
import 'package:otraku/util/paged_controller.dart';
import 'package:otraku/feature/media/media_overview_view.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/widget/layout/adaptive_scaffold.dart';
import 'package:otraku/widget/layout/constrained_view.dart';
import 'package:otraku/widget/layout/hiding_floating_action_button.dart';
import 'package:otraku/widget/layout/dual_pane_with_tab_bar.dart';
import 'package:otraku/widget/loaders.dart';
import 'package:otraku/feature/media/media_header.dart';

class MediaView extends StatefulWidget {
  const MediaView(this.id, this.coverUrl);

  final int id;
  final String? coverUrl;

  @override
  State<MediaView> createState() => _MediaViewState();
}

class _MediaViewState extends State<MediaView> {
  final _scrollCtrl = ScrollController();

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        ref.listen<AsyncValue>(mediaProvider(widget.id), (_, s) {
          if (s.hasError) {
            SnackBarExtension.show(context, 'Failed to load media: ${s.error}');
          }
        });

        final media = ref.watch(mediaProvider(widget.id));

        final toggleFavorite = () => ref.read(mediaProvider(widget.id).notifier).toggleFavorite();

        return AdaptiveScaffold(
          floatingAction: media.value != null
              ? HidingFloatingActionButton(
                  key: const Key('edit'),
                  scrollCtrl: _scrollCtrl,
                  child: MediaEditButton(media.value!),
                )
              : null,
          child: switch (Theming.of(context).formFactor) {
            .phone => _CompactView(
              id: widget.id,
              coverUrl: widget.coverUrl,
              media: media,
              scrollCtrl: _scrollCtrl,
              toggleFavorite: toggleFavorite,
            ),
            .tablet => _LargeView(
              id: widget.id,
              coverUrl: widget.coverUrl,
              ref: ref,
              media: media,
              scrollCtrl: _scrollCtrl,
              toggleFavorite: toggleFavorite,
            ),
          },
        );
      },
    );
  }
}

class _CompactView extends StatefulWidget {
  const _CompactView({
    required this.id,
    required this.coverUrl,
    required this.media,
    required this.scrollCtrl,
    required this.toggleFavorite,
  });

  final int id;
  final String? coverUrl;
  final AsyncValue<Media> media;
  final ScrollController scrollCtrl;
  final Future<Object?> Function() toggleFavorite;

  @override
  State<_CompactView> createState() => _CompactViewState();
}

class _CompactViewState extends State<_CompactView> with SingleTickerProviderStateMixin {
  late final _tabCtrl = TabController(length: MediaHeader.tabsWithOverview.length, vsync: this);

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    final header = MediaHeader.withTabBar(
      id: widget.id,
      coverUrl: widget.coverUrl,
      media: widget.media.value,
      tabCtrl: _tabCtrl,
      scrollToTop: widget.scrollCtrl.scrollToTop,
      toggleFavorite: widget.toggleFavorite,
    );

    return NestedScrollView(
      controller: widget.scrollCtrl,
      headerSliverBuilder: (context, _) => [header],
      body: MediaQuery(
        data: mediaQuery.copyWith(padding: mediaQuery.padding.copyWith(top: 0)),
        child: widget.media.unwrapPrevious().when(
          loading: () => const Center(child: Loader()),
          error: (_, _) => const Center(child: Text('Failed to load media')),
          data: (data) => _MediaTabs.withOverview(id: widget.id, media: data, tabCtrl: _tabCtrl),
        ),
      ),
    );
  }
}

class _LargeView extends StatefulWidget {
  const _LargeView({
    required this.id,
    required this.coverUrl,
    required this.ref,
    required this.media,
    required this.scrollCtrl,
    required this.toggleFavorite,
  });

  final int id;
  final String? coverUrl;
  final WidgetRef ref;
  final AsyncValue<Media> media;
  final ScrollController scrollCtrl;
  final Future<Object?> Function() toggleFavorite;

  @override
  State<_LargeView> createState() => _LargeViewState();
}

class _LargeViewState extends State<_LargeView> with SingleTickerProviderStateMixin {
  late final _tabCtrl = TabController(length: MediaHeader.tabsWithoutOverview.length, vsync: this);

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final options = widget.ref.read(persistenceProvider.select((s) => s.options));

    final header = MediaHeader.withoutTabBar(
      id: widget.id,
      coverUrl: widget.coverUrl,
      media: widget.media.value,
      toggleFavorite: widget.toggleFavorite,
    );

    return DualPaneWithTabBar(
      tabCtrl: _tabCtrl,
      scrollToTop: widget.scrollCtrl.scrollToTop,
      tabs: MediaHeader.tabsWithoutOverview,
      leftPane: widget.media.unwrapPrevious().when(
        loading: () => CustomScrollView(
          physics: Theming.bouncyPhysics,
          slivers: [
            header,
            const SliverFillRemaining(child: Center(child: Loader())),
          ],
        ),
        error: (_, _) => CustomScrollView(
          physics: Theming.bouncyPhysics,
          slivers: [
            header,
            const SliverFillRemaining(child: Center(child: Text('Failed to load media'))),
          ],
        ),
        data: (data) => MediaOverviewSubview.withHeader(
          ref: widget.ref,
          info: data.info,
          header: header,
          highContrast: options.highContrast,
        ),
      ),
      rightPane: widget.media.unwrapPrevious().maybeWhen(
        data: (data) => _MediaTabs.withoutOverview(
          id: widget.id,
          media: data,
          tabCtrl: _tabCtrl,
          scrollCtrl: widget.scrollCtrl,
        ),
        orElse: () => const SizedBox(),
      ),
    );
  }
}

/// When [withOverview], [_MediaTabs] requires a [NestedScrollView] ancestor.
///
/// Due to [NestedScrollView] limitations, the custom [PagedController]
/// can't be used here and has to be reimplemented temporarely on the inner
/// scroll controller of the [NestedScrollView].
/// For more context: https://github.com/flutter/flutter/pull/104166.
class _MediaTabs extends ConsumerStatefulWidget {
  const _MediaTabs.withOverview({required this.id, required this.media, required this.tabCtrl})
    : withOverview = true,
      scrollCtrl = null;

  const _MediaTabs.withoutOverview({
    required this.id,
    required this.media,
    required this.tabCtrl,
    required ScrollController this.scrollCtrl,
  }) : withOverview = false;

  final int id;
  final Media media;
  final TabController tabCtrl;
  final ScrollController? scrollCtrl;
  final bool withOverview;

  @override
  ConsumerState<_MediaTabs> createState() => __MediaSubViewState();
}

class __MediaSubViewState extends ConsumerState<_MediaTabs> {
  late final _mediaActivitiesTag = MediaActivitiesTag(widget.id);
  late final ScrollController _scrollCtrl;
  double _lastMaxExtent = 0;

  @override
  void initState() {
    super.initState();
    _scrollCtrl =
        widget.scrollCtrl ??
        context.findAncestorStateOfType<NestedScrollViewState>()!.innerController;

    _scrollCtrl.addListener(_scrollListener);
    widget.tabCtrl.addListener(_tabListener);
  }

  @override
  void deactivate() {
    // These pages are lazy-loaded and then kept alive until the media page is popped.
    ref.invalidate(mediaThreadsProvider(widget.id));
    ref.invalidate(mediaFollowingProvider(widget.id));
    ref.invalidate(activitiesProvider(_mediaActivitiesTag));
    super.deactivate();
  }

  @override
  void dispose() {
    _scrollCtrl.removeListener(_scrollListener);
    widget.tabCtrl.removeListener(_tabListener);
    super.dispose();
  }

  void _tabListener() {
    _lastMaxExtent = 0;

    // This is a workaround for an issue with [NestedScrollView].
    // If you switch to a tab with pagination, where the content
    // doesn't fill the view, the scroll controller has it's maximum
    // extent set to 0 and the loading of a next page of items is not triggered.
    // This is why we need to manually load the second page.
    if (!widget.tabCtrl.indexIsChanging && _scrollCtrl.hasClients) {
      final pos = _scrollCtrl.positions.last;
      if (pos.minScrollExtent == pos.maxScrollExtent) _loadNextPage();
    }
  }

  void _scrollListener() {
    final pos = _scrollCtrl.positions.last;
    if (pos.pixels < pos.maxScrollExtent - 100) return;
    if (_lastMaxExtent == pos.maxScrollExtent) return;

    _lastMaxExtent = pos.maxScrollExtent;
    _loadNextPage();
  }

  void _loadNextPage() {
    final index = widget.withOverview ? widget.tabCtrl.index : widget.tabCtrl.index + 1;

    if (index == MediaTab.threads.index) {
      ref.read(mediaThreadsProvider(widget.id).notifier).fetch();
    } else if (index == MediaTab.following.index) {
      ref.read(mediaFollowingProvider(widget.id).notifier).fetch();
    } else if (index == MediaTab.activities.index) {
      ref.read(activitiesProvider(_mediaActivitiesTag).notifier).fetch();
    } else {
      ref
          .read(mediaConnectionsProvider(widget.id).notifier)
          .fetch(MediaTab.values.elementAt(index));
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(mediaConnectionsProvider(widget.id).select((_) => null));

    final viewerId = ref.watch(viewerIdProvider);
    final options = ref.watch(persistenceProvider.select((s) => s.options));

    return TabBarView(
      controller: widget.tabCtrl,
      children: [
        if (widget.withOverview)
          ConstrainedView(
            padded: false,
            child: MediaOverviewSubview.asFragment(
              ref: ref,
              info: widget.media.info,
              scrollCtrl: _scrollCtrl,
              highContrast: options.highContrast,
            ),
          ),
        MediaRelatedSubview(
          relations: widget.media.related,
          scrollCtrl: _scrollCtrl,
          invalidate: () => ref.invalidate(mediaProvider(widget.id)),
          highContrast: options.highContrast,
        ),
        MediaCharactersSubview(
          id: widget.id,
          scrollCtrl: _scrollCtrl,
          highContrast: options.highContrast,
        ),
        MediaStaffSubview(
          id: widget.id,
          scrollCtrl: _scrollCtrl,
          highContrast: options.highContrast,
        ),
        MediaReviewsSubview(
          id: widget.id,
          scrollCtrl: _scrollCtrl,
          bannerUrl: widget.media.info.banner,
          highContrast: options.highContrast,
        ),
        MediaThreadsSubview(
          id: widget.id,
          scrollCtrl: _scrollCtrl,
          highContrast: options.highContrast,
          analogClock: options.analogClock,
        ),
        MediaFollowingSubview(
          id: widget.id,
          scrollCtrl: _scrollCtrl,
          highContrast: options.highContrast,
        ),
        MediaActivitiesSubview(
          ref: ref,
          tag: _mediaActivitiesTag,
          scrollCtrl: _scrollCtrl,
          viewerId: viewerId,
          options: options,
        ),
        MediaRecommendationsSubview(
          id: widget.id,
          scrollCtrl: _scrollCtrl,
          rateRecommendation: ref
              .read(mediaConnectionsProvider(widget.id).notifier)
              .rateRecommendation,
          highContrast: options.highContrast,
        ),
        MediaStatsSubview(
          ref: ref,
          info: widget.media.info,
          stats: widget.media.stats,
          scrollCtrl: _scrollCtrl,
          highContrast: options.highContrast,
        ),
      ],
    );
  }
}
