import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/media/media_models.dart';
import 'package:otraku/media/media_providers.dart';
import 'package:otraku/utils/paged_controller.dart';
import 'package:otraku/media/media_info_view.dart';
import 'package:otraku/media/media_other_view.dart';
import 'package:otraku/media/media_people_view.dart';
import 'package:otraku/media/media_social_view.dart';
import 'package:otraku/widgets/layouts/bottom_bar.dart';
import 'package:otraku/widgets/layouts/scaffolds.dart';
import 'package:otraku/widgets/layouts/direct_page_view.dart';
import 'package:otraku/widgets/loaders.dart/loaders.dart';
import 'package:otraku/media/media_header.dart';
import 'package:otraku/widgets/overlays/dialogs.dart';

class MediaView extends StatefulWidget {
  const MediaView(this.id, this.coverUrl);

  final int id;
  final String? coverUrl;

  @override
  State<MediaView> createState() => _MediaViewState();
}

class _MediaViewState extends State<MediaView> {
  final _scrollCtrl = ScrollController();
  int _tab = 0;

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      bottomBar: BottomBarIconTabs(
        current: _tab,
        onChanged: (i) => setState(() => _tab = i),
        onSame: (_) => _scrollCtrl.scrollToTop(),
        items: const {
          'Info': Ionicons.book_outline,
          'Other': Ionicons.layers_outline,
          'People': Icons.emoji_people_outlined,
          'Social': Ionicons.stats_chart_outline,
        },
      ),
      child: Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).viewPadding.top),
        child: NestedScrollView(
          controller: _scrollCtrl,
          headerSliverBuilder: (context, _) => [
            SliverOverlapAbsorber(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              sliver: MediaHeader(widget.id, widget.coverUrl),
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

              return ref.watch(mediaProvider(widget.id)).when(
                    loading: () => const Center(child: Loader()),
                    error: (_, __) =>
                        const Center(child: Text('Failed to load media')),
                    data: (media) => _MediaView(
                      widget.id,
                      _tab,
                      media,
                      (i) => setState(() => _tab = i),
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
class _MediaView extends ConsumerStatefulWidget {
  const _MediaView(this.id, this.tab, this.media, this.onChanged);

  final int id;
  final int tab;
  final Media media;
  final void Function(int) onChanged;

  @override
  ConsumerState<_MediaView> createState() => __MediaSubViewState();
}

class __MediaSubViewState extends ConsumerState<_MediaView> {
  late final ScrollController _scrollCtrl;
  double _lastMaxExtent = 0;
  bool _otherTabToggled = false;
  bool _peopleTabToggled = false;
  bool _socialTabToggled = false;

  @override
  void initState() {
    super.initState();
    _scrollCtrl = context
        .findAncestorStateOfType<NestedScrollViewState>()!
        .innerController;
    _scrollCtrl.addListener(_listener);
  }

  @override
  void didUpdateWidget(covariant _MediaView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.tab != oldWidget.tab) _lastMaxExtent = 0;
  }

  @override
  void dispose() {
    _scrollCtrl.removeListener(_listener);
    super.dispose();
  }

  void _listener() {
    final pos = _scrollCtrl.positions.last;
    if (pos.pixels < pos.maxScrollExtent - 100) return;
    if (_lastMaxExtent == pos.maxScrollExtent) return;

    _lastMaxExtent = pos.maxScrollExtent;
    switch (widget.tab) {
      case 1:
        if (_otherTabToggled) {
          ref.read(mediaContentProvider(widget.id)).fetchRecommended();
        }
        return;
      case 2:
        _peopleTabToggled
            ? ref.read(mediaContentProvider(widget.id)).fetchStaff()
            : ref.read(mediaContentProvider(widget.id)).fetchCharacters();
        return;
      case 3:
        if (!_socialTabToggled) {
          ref.read(mediaContentProvider(widget.id)).fetchReviews();
        }
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(mediaContentProvider(widget.id).select((_) => null));

    return DirectPageView(
      current: widget.tab,
      onChanged: widget.onChanged,
      children: [
        MediaInfoView(widget.media),
        MediaOtherView(
          widget.id,
          widget.media.relations,
          _otherTabToggled,
          (val) {
            _lastMaxExtent = 0;
            _scrollCtrl.scrollToTop();
            setState(() => _otherTabToggled = val);
          },
        ),
        MediaPeopleView(
          widget.id,
          _peopleTabToggled,
          (val) {
            _lastMaxExtent = 0;
            _scrollCtrl.scrollToTop();
            setState(() => _peopleTabToggled = val);
          },
        ),
        MediaSocialView(
          widget.id,
          widget.media,
          _socialTabToggled,
          (val) {
            _lastMaxExtent = 0;
            _scrollCtrl.scrollToTop();
            setState(() => _socialTabToggled = val);
          },
        ),
      ],
    );
  }
}
