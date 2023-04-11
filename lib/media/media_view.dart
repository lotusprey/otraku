import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/common/relation.dart';
import 'package:otraku/media/media_action_buttons.dart';
import 'package:otraku/media/media_grids.dart';
import 'package:otraku/media/media_models.dart';
import 'package:otraku/media/media_providers.dart';
import 'package:otraku/statistics/charts.dart';
import 'package:otraku/utils/paged_controller.dart';
import 'package:otraku/media/media_info_view.dart';
import 'package:otraku/widgets/grids/relation_grid.dart';
import 'package:otraku/widgets/layouts/constrained_view.dart';
import 'package:otraku/widgets/layouts/floating_bar.dart';
import 'package:otraku/widgets/layouts/scaffolds.dart';
import 'package:otraku/widgets/loaders.dart/loaders.dart';
import 'package:otraku/media/media_header.dart';
import 'package:otraku/widgets/overlays/dialogs.dart';
import 'package:otraku/widgets/paged_view.dart';

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
      child: Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).viewPadding.top),
        child: NestedScrollView(
          controller: _scrollCtrl,
          headerSliverBuilder: (context, _) => [
            MediaHeader(widget.id, widget.coverUrl, _tabCtrl),
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

  void _tabListener() => _lastMaxExtent = 0;

  void _scrollListener() {
    final pos = _scrollCtrl.positions.last;
    if (pos.pixels < pos.maxScrollExtent - 100) return;
    if (_lastMaxExtent == pos.maxScrollExtent) return;

    _lastMaxExtent = pos.maxScrollExtent;
    ref
        .read(mediaRelationsProvider(widget.id).notifier)
        .fetch(MediaTab.values.elementAt(widget.tabCtrl.index));
  }

  void _refresh(WidgetRef ref) {
    ref.invalidate(mediaRelationsProvider(widget.id));
    _lastMaxExtent = 0;
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(mediaRelationsProvider(widget.id).select((_) => null));

    final stats = widget.media.stats;

    return TabBarView(
      controller: widget.tabCtrl,
      children: [
        MediaInfoView(widget.media, _scrollCtrl),
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
                return RelationGrid(items: data.items);
              }

              final characters = <Relation>[];
              final voiceActors = <Relation?>[];
              mediaRelations.getCharactersAndVoiceActors(
                characters,
                voiceActors,
              );

              return RelationGrid(items: characters, connections: voiceActors);
            },
          ),
        ),
        Consumer(
          builder: (context, ref, _) => PagedView<Relation>(
            provider: mediaRelationsProvider(widget.id).select((s) => s.staff),
            onData: (data) => RelationGrid(items: data.items),
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
          builder: (context, ref, _) => PagedView<Recommendation>(
            provider: mediaRelationsProvider(widget.id).select(
              (s) => s.recommendations,
            ),
            onData: (data) => MediaRecommendationGrid(widget.id, data.items),
            onRefresh: () => _refresh(ref),
            scrollCtrl: _scrollCtrl,
          ),
        ),
        CustomScrollView(
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
      ],
    );
  }
}
