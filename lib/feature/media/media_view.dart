import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/extension/scaffold_extension.dart';
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
import 'package:otraku/util/paged_controller.dart';
import 'package:otraku/feature/media/media_overview_view.dart';
import 'package:otraku/widget/loaders/loaders.dart';
import 'package:otraku/feature/media/media_header.dart';
import 'package:otraku/widget/overlays/dialogs.dart';

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
    return Consumer(
      builder: (context, ref, _) {
        ref.listen<AsyncValue>(
          mediaProvider(widget.id),
          (_, s) {
            if (s.hasError) {
              showDialog(
                context: context,
                builder: (context) => ConfirmationDialog(
                  title: 'Failed to load media',
                  content: s.error.toString(),
                ),
              );
            }
          },
        );

        final media = ref.watch(mediaProvider(widget.id));

        return ScaffoldExtension.expanded(
          floatingActionConfig: (
            scrollCtrl: _scrollCtrl,
            actions: media.valueOrNull != null
                ? [
                    MediaEditButton(media.value!),
                    MediaFavoriteButton(
                      media.value!.info,
                      ref
                          .read(mediaProvider(widget.id).notifier)
                          .toggleFavorite,
                    ),
                    MediaLanguageButton(widget.id, _tabCtrl),
                  ]
                : const [],
          ),
          child: NestedScrollView(
            controller: _scrollCtrl,
            headerSliverBuilder: (context, _) => [
              MediaHeader(
                id: widget.id,
                coverUrl: widget.coverUrl,
                media: media.valueOrNull,
                tabCtrl: _tabCtrl,
                scrollToTop: _scrollCtrl.scrollToTop,
              ),
            ],
            body: media.unwrapPrevious().when(
                  loading: () => const Center(child: Loader()),
                  error: (_, __) => const Center(
                    child: Text('Failed to load media'),
                  ),
                  data: (media) => _MediaViewContent(
                    widget.id,
                    media,
                    _tabCtrl,
                  ),
                ),
          ),
        );
      },
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
  void deactivate() {
    ref.invalidate(mediaFollowingProvider(widget.id));
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
    if (widget.tabCtrl.index == MediaTab.following.index) {
      ref.read(mediaFollowingProvider(widget.id).notifier).fetch();
    } else {
      ref
          .read(mediaRelationsProvider(widget.id).notifier)
          .fetch(MediaTab.values.elementAt(widget.tabCtrl.index));
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(mediaRelationsProvider(widget.id).select((_) => null));

    return TabBarView(
      controller: widget.tabCtrl,
      children: [
        MediaOverviewSubview(
          info: widget.media.info,
          scrollCtrl: _scrollCtrl,
          invalidate: () => ref.invalidate(mediaProvider(widget.id)),
        ),
        MediaRelatedSubview(
          relations: widget.media.related,
          scrollCtrl: _scrollCtrl,
          invalidate: () => ref.invalidate(mediaProvider(widget.id)),
        ),
        MediaCharactersSubview(id: widget.id, scrollCtrl: _scrollCtrl),
        MediaStaffSubview(id: widget.id, scrollCtrl: _scrollCtrl),
        MediaReviewsSubview(
          id: widget.id,
          scrollCtrl: _scrollCtrl,
          bannerUrl: widget.media.info.banner,
        ),
        MediaFollowingSubview(id: widget.id, scrollCtrl: _scrollCtrl),
        MediaRecommendationsSubview(
          id: widget.id,
          scrollCtrl: _scrollCtrl,
          rateRecommendation: ref
              .read(mediaRelationsProvider(widget.id).notifier)
              .rateRecommendation,
        ),
        MediaStatsSubview(
          ref: ref,
          info: widget.media.info,
          stats: widget.media.stats,
          scrollCtrl: _scrollCtrl,
        ),
      ],
    );
  }
}
