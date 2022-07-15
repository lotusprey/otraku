import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/controllers/media_controller.dart';
import 'package:otraku/settings/user_settings.dart';
import 'package:otraku/utils/pagination_controller.dart';
import 'package:otraku/views/media_info_view.dart';
import 'package:otraku/views/media_other_view.dart';
import 'package:otraku/views/media_people_view.dart';
import 'package:otraku/views/media_social_view.dart';
import 'package:otraku/widgets/layouts/bottom_bar.dart';
import 'package:otraku/widgets/layouts/page_layout.dart';
import 'package:otraku/widgets/layouts/tab_switcher.dart';
import 'package:otraku/widgets/loaders.dart/loaders.dart';
import 'package:otraku/widgets/navigation/media_header.dart';

class MediaView extends StatelessWidget {
  MediaView(this.id, this.coverUrl);

  final int id;
  final String? coverUrl;

  @override
  Widget build(BuildContext context) => Consumer(
        builder: (context, ref, _) => GetBuilder<MediaController>(
          init: MediaController(id, ref.watch(userSettingsProvider)),
          id: MediaController.ID_BASE,
          tag: id.toString(),
          builder: (ctrl) => _MediaView(id, coverUrl, ctrl),
        ),
      );
}

class _MediaView extends ConsumerStatefulWidget {
  _MediaView(this.id, this.coverUrl, this.ctrl);

  final int id;
  final String? coverUrl;
  final MediaController ctrl;

  @override
  ConsumerState<_MediaView> createState() => __MediaViewState();
}

class __MediaViewState extends ConsumerState<_MediaView> {
  late final PaginationController _innerCtrl;
  final _outerCtrl = ScrollController();
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    _innerCtrl = PaginationController(loadMore: () {
      switch (_tab) {
        case 1:
          widget.ctrl.fetchRecommendations();
          return;
        case 2:
          widget.ctrl.peopleTabToggled
              ? widget.ctrl.fetchStaff()
              : widget.ctrl.fetchCharacters();
          return;
        case 3:
          widget.ctrl.fetchReviews();
          return;
      }
    });
  }

  @override
  void dispose() {
    _innerCtrl.dispose();
    _outerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageLayout(
      bottomBar: BottomBarIconTabs(
        current: _tab,
        onChanged: (i) => setState(() => _tab = i),
        onSame: (_) => _outerCtrl.scrollToTop(),
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
          controller: _outerCtrl,
          headerSliverBuilder: (context, _) => [
            SliverOverlapAbsorber(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              sliver: MediaHeader(ctrl: widget.ctrl, imageUrl: widget.coverUrl),
            ),
          ],
          body: widget.ctrl.model != null
              ? _MediaSubView(
                  widget.id,
                  widget.ctrl,
                  _tab,
                  (i) => setState(() => _tab = i),
                )
              : const Center(child: Loader()),
        ),
      ),
    );
  }
}

class _MediaSubView extends StatefulWidget {
  _MediaSubView(this.id, this.ctrl, this.tab, this.onChanged);

  final int id;
  final MediaController ctrl;
  final int tab;
  final void Function(int) onChanged;

  @override
  State<_MediaSubView> createState() => __MediaSubViewState();
}

/// I absolutely hate this, but due to limitations of the current
/// [NestedScrollView], the custom [PaginationController] can't be
/// used here and it has to be reimplemented temporarely.
/// Hopefully, this will help https://github.com/flutter/flutter/pull/104166.
class __MediaSubViewState extends State<_MediaSubView> {
  bool _didInit = false;
  double _lastMaxExtent = 0;
  late final _scrollCtrl;

  void _listener() {
    final pos = _scrollCtrl.positions.last;
    if (pos.pixels < pos.maxScrollExtent - 100) return;
    if (_lastMaxExtent == pos.maxScrollExtent) return;

    _lastMaxExtent = pos.maxScrollExtent;
    switch (widget.tab) {
      case 1:
        widget.ctrl.fetchRecommendations();
        return;
      case 2:
        widget.ctrl.peopleTabToggled
            ? widget.ctrl.fetchStaff()
            : widget.ctrl.fetchCharacters();
        return;
      case 3:
        widget.ctrl.fetchReviews();
        return;
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollCtrl = context
        .findAncestorStateOfType<NestedScrollViewState>()!
        .innerController;
  }

  @override
  void didUpdateWidget(covariant _MediaSubView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.tab != oldWidget.tab) _lastMaxExtent = 0;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didInit) return;
    _didInit = true;
    _scrollCtrl.addListener(_listener);
    Get.find<MediaController>(tag: widget.id.toString())
        .addListenerId(MediaController.ID_INNER, () => _lastMaxExtent = 0);
  }

  @override
  void dispose() {
    _scrollCtrl.removeListener(_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MediaController>(
      id: MediaController.ID_INNER,
      tag: widget.id.toString(),
      builder: (ctrl) => TabSwitcher(
        current: widget.tab,
        onChanged: widget.onChanged,
        children: [
          MediaInfoView(ctrl),
          MediaOtherView(ctrl),
          MediaPeopleView(ctrl),
          MediaSocialView(ctrl),
        ],
      ),
    );
  }
}
