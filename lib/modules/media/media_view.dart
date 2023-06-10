import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/common/models/relation.dart';
import 'package:otraku/modules/media/media_action_buttons.dart';
import 'package:otraku/modules/media/media_grids.dart';
import 'package:otraku/modules/media/media_models.dart';
import 'package:otraku/modules/media/media_providers.dart';
import 'package:otraku/modules/statistics/charts.dart';
import 'package:otraku/common/utils/paged_controller.dart';
import 'package:otraku/modules/media/media_info_view.dart';
import 'package:otraku/common/widgets/grids/relation_grid.dart';
import 'package:otraku/common/widgets/layouts/constrained_view.dart';
import 'package:otraku/common/widgets/layouts/floating_bar.dart';
import 'package:otraku/common/widgets/layouts/scaffolds.dart';
import 'package:otraku/common/widgets/loaders.dart/loaders.dart';
import 'package:otraku/modules/media/media_header.dart';
import 'package:otraku/common/widgets/overlays/dialogs.dart';
import 'package:otraku/common/widgets/paged_view.dart';

class MediaView extends StatefulWidget {
  const MediaView(this.id, this.coverUrl);

  final int id;
  final String? coverUrl;

  @override
  State<MediaView> createState() => _MediaViewState();
}

class _MediaViewState extends State<MediaView>
    with SingleTickerProviderStateMixin {
  final _scrollCtrl = ScrollController();
  late final _tabCtrl = TabController(
    length: MediaTab.values.length,
    vsync: this,
  );

  @override
  void dispose() {
    _scrollCtrl.dispose();
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      child: NestedScrollView(
        controller: _scrollCtrl,
        headerSliverBuilder: (context, _) => [
          MediaHeader(
            id: widget.id,
            coverUrl: widget.coverUrl,
            tabCtrl: _tabCtrl,
            scrollToTop: _scrollCtrl.scrollToTop,
          ),
        ],
        body: Consumer(
          builder: (context, ref, _) {
            ref.listen<AsyncValue>(
              mediaProvider(widget.id),
              (_, s) {
                if (s.hasError) {
                  showPopUp(
                    context,
                    ConfirmationDialog(
                      title: 'Failed to load media',
                      content: s.error.toString(),
                    ),
                  );
                }
              },
            );

            final innerScrollCtrl = context
                .findAncestorStateOfType<NestedScrollViewState>()!
                .innerController;

            return ref.watch(mediaProvider(widget.id)).when(
                  loading: () => const Center(child: Loader()),
                  error: (_, __) => const Center(
                    child: Text('Failed to load media'),
                  ),
                  data: (media) => TabScaffold(
                    floatingBar: FloatingBar(
                      scrollCtrl: innerScrollCtrl,
                      children: [
                        MediaEditButton(media),
                        MediaFavoriteButton(media.info),
                        MediaLanguageButton(widget.id, _tabCtrl),
                      ],
                    ),
                    child: _MediaViewContent(widget.id, media, _tabCtrl),
                  ),
                );
          },
        ),
      ),
    );
  }
}

/// Due to [NestedScrollView] limitations, the custom [PagedController]
/// can't be used here and has to be reimplemented temporarely on the inner
/// scroll controller of the [NestedScrollView].
/// For more context: https://github.com/flutter/flutter/pull/104166.
class _MediaViewContent extends ConsumerStatefulWidget {
  const _MediaViewContent(this.id, this.media, this.tabCtrl);

  final int id;
  final Media media;
  final TabController tabCtrl;

  @override
  ConsumerState<_MediaViewContent> createState() => __MediaSubViewState();
}

class __MediaSubViewState extends ConsumerState<_MediaViewContent> {
  late final ScrollController _scrollCtrl;
  double _lastMaxExtent = 0;

  @override
  void initState() {
    super.initState();
    _scrollCtrl = context
        .findAncestorStateOfType<NestedScrollViewState>()!
        .innerController;
    _scrollCtrl.addListener(_scrollListener);
    widget.tabCtrl.addListener(_tabListener);
  }

  @override
  void dispose() {
    _scrollCtrl.removeListener(_scrollListener);
    widget.tabCtrl.removeListener(_tabListener);
    super.dispose();
  }

  void _tabListener() {
    _lastMaxExtent = 0;

    if (widget.tabCtrl.index == MediaTab.following.index) {
      ref.read(mediaFollowingProvider(widget.id).notifier).lazyLoad();
    }

    // This is a workaround for an issue with [NestedScrollView].
    // If you switch to a tab with pagination, where the content
    // doesn't fill the view, the scroll controller has it's maximum
    // extent set to 0 and the loading of a next page of items is not triggered.
    // This is why we need to manually load the second page.
    if (!widget.tabCtrl.indexIsChanging) {
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
    if (widget.tabCtrl.index == MediaTab.following.index) {
      ref.read(mediaFollowingProvider(widget.id).notifier).fetch();
    } else {
      ref
          .read(mediaRelationsProvider(widget.id).notifier)
          .fetch(MediaTab.values.elementAt(widget.tabCtrl.index));
    }
  }

  void _refresh(WidgetRef ref) {
    if (widget.tabCtrl.index == MediaTab.following.index) {
      ref.invalidate(mediaFollowingProvider(widget.id));
    } else {
      ref.invalidate(mediaRelationsProvider(widget.id));
    }
    _lastMaxExtent = 0;
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(mediaRelationsProvider(widget.id).select((_) => null));
    ref.watch(mediaFollowingProvider(widget.id).select((_) => null));

    final stats = widget.media.stats;

    return TabBarView(
      controller: widget.tabCtrl,
      children: [
        ConstrainedView(child: MediaInfoView(widget.media, _scrollCtrl)),
        ConstrainedView(
          child: CustomScrollView(
            controller: _scrollCtrl,
            slivers: [
              const SliverToBoxAdapter(child: SizedBox(height: 10)),
              MediaRelatedGrid(widget.media.relations),
              const SliverFooter(),
            ],
          ),
        ),
        Consumer(
          builder: (context, ref, _) => PagedView<Relation>(
            provider: mediaRelationsProvider(widget.id).select(
              (s) => s.characters,
            ),
            scrollCtrl: _scrollCtrl,
            onRefresh: () => _refresh(ref),
            onData: (data) {
              final mediaRelations = ref.watch(
                mediaRelationsProvider(widget.id),
              );

              if (mediaRelations.languages.isEmpty) {
                return SingleRelationGrid(data.items);
              }

              return RelationGrid(
                mediaRelations.getCharactersAndVoiceActors(),
              );
            },
          ),
        ),
        Consumer(
          builder: (context, ref, _) => PagedView<Relation>(
            provider: mediaRelationsProvider(widget.id).select((s) => s.staff),
            onData: (data) => SingleRelationGrid(data.items),
            scrollCtrl: _scrollCtrl,
            onRefresh: () => _refresh(ref),
          ),
        ),
        Consumer(
          builder: (context, ref, _) => PagedView<RelatedReview>(
            provider: mediaRelationsProvider(widget.id).select(
              (s) => s.reviews,
            ),
            onData: (data) => MediaReviewGrid(
              data.items,
              widget.media.info.banner,
            ),
            scrollCtrl: _scrollCtrl,
            onRefresh: () => _refresh(ref),
          ),
        ),
        Consumer(
          builder: (context, ref, _) => PagedView<MediaFollowing>(
            provider: mediaFollowingProvider(widget.id),
            onData: (data) => MediaFollowingGrid(data.items),
            scrollCtrl: _scrollCtrl,
            onRefresh: () => _refresh(ref),
          ),
        ),
        Consumer(
          builder: (context, ref, _) => PagedView<Recommendation>(
            provider: mediaRelationsProvider(widget.id).select(
              (s) => s.recommendations,
            ),
            onData: (data) => MediaRecommendationGrid(widget.id, data.items),
            onRefresh: () => _refresh(ref),
            scrollCtrl: _scrollCtrl,
          ),
        ),
        ConstrainedView(
          child: CustomScrollView(
            controller: _scrollCtrl,
            slivers: [
              if (stats.rankTexts.isNotEmpty)
                MediaRankGrid(stats.rankTexts, stats.rankTypes),
              if (stats.scoreNames.isNotEmpty)
                SliverToBoxAdapter(
                  child: BarChart(
                    title: 'Score Distribution',
                    names: stats.scoreNames.map((n) => n.toString()).toList(),
                    values: stats.scoreValues,
                  ),
                ),
              if (stats.statusNames.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: PieChart(
                      title: 'Status Distribution',
                      names: stats.statusNames,
                      values: stats.statusValues,
                    ),
                  ),
                ),
              const SliverFooter(),
            ],
          ),
        ),
      ],
    );
  }
}
