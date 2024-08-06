import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/feature/staff/staff_header.dart';
import 'package:otraku/feature/staff/staff_model.dart';
import 'package:otraku/widget/layouts/adaptive_scaffold.dart';
import 'package:otraku/widget/loaders/loaders.dart';
import 'package:otraku/feature/staff/staff_floating_actions.dart';
import 'package:otraku/feature/staff/staff_characters_view.dart';
import 'package:otraku/feature/staff/staff_overview_view.dart';
import 'package:otraku/feature/staff/staff_provider.dart';
import 'package:otraku/util/paged_controller.dart';
import 'package:otraku/widget/overlays/dialogs.dart';
import 'package:otraku/feature/staff/staff_roles_view.dart';

class StaffView extends ConsumerStatefulWidget {
  const StaffView(this.id, this.imageUrl);

  final int id;
  final String? imageUrl;

  @override
  ConsumerState<StaffView> createState() => _StaffViewState();
}

class _StaffViewState extends ConsumerState<StaffView>
    with SingleTickerProviderStateMixin {
  late final _tabCtrl = TabController(length: 3, vsync: this);
  late final _scrollCtrl = PagedController(loadMore: () {
    if (_tabCtrl.index == 0) return;
    _tabCtrl.index == 1
        ? ref.read(staffRelationsProvider(widget.id).notifier).fetch(true)
        : ref.read(staffRelationsProvider(widget.id).notifier).fetch(false);
  });

  @override
  void initState() {
    super.initState();
    _tabCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue>(
      staffProvider(widget.id),
      (_, s) {
        if (s.hasError) {
          showDialog(
            context: context,
            builder: (context) => ConfirmationDialog(
              title: 'Failed to load staff',
              content: s.error.toString(),
            ),
          );
        }
      },
    );

    final staff = ref.watch(staffProvider(widget.id));
    final mediaQuery = MediaQuery.of(context);

    return AdaptiveScaffold(
      floatingActionConfig: FloatingActionConfig(
        scrollCtrl: _scrollCtrl,
        actions: [
          if (_tabCtrl.index > 0) StaffFilterButton(widget.id, ref),
        ],
      ),
      builder: (context, _) => NestedScrollView(
        controller: _scrollCtrl,
        headerSliverBuilder: (context, _) => [
          StaffHeader(
            id: widget.id,
            imageUrl: widget.imageUrl,
            staff: staff.valueOrNull,
            tabCtrl: _tabCtrl,
            scrollToTop: _scrollCtrl.scrollToTop,
            toggleFavorite: () =>
                ref.read(staffProvider(widget.id).notifier).toggleFavorite(),
          ),
        ],
        body: MediaQuery(
          data: mediaQuery.copyWith(
            padding: mediaQuery.padding.copyWith(top: 0),
          ),
          child: staff.unwrapPrevious().when(
                loading: () => const Center(child: Loader()),
                error: (_, __) => const Center(
                  child: Text('Failed to load staff'),
                ),
                data: (staff) => _StaffViewContent(
                  widget.id,
                  staff,
                  _tabCtrl,
                ),
              ),
        ),
      ),
    );
  }
}

class _StaffViewContent extends ConsumerStatefulWidget {
  const _StaffViewContent(this.id, this.staff, this.tabCtrl);

  final int id;
  final Staff staff;
  final TabController tabCtrl;

  @override
  ConsumerState<_StaffViewContent> createState() => __StaffViewContentState();
}

class __StaffViewContentState extends ConsumerState<_StaffViewContent> {
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
    if (widget.tabCtrl.index < 1) return;
    ref
        .read(staffRelationsProvider(widget.id).notifier)
        .fetch(widget.tabCtrl.index == 1);
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(staffRelationsProvider(widget.id).select((_) => null));

    return TabBarView(
      controller: widget.tabCtrl,
      children: [
        StaffOverviewSubview(
          staff: widget.staff,
          scrollCtrl: _scrollCtrl,
          invalidate: () => ref.invalidate(staffProvider(widget.id)),
        ),
        StaffCharactersSubview(id: widget.id, scrollCtrl: _scrollCtrl),
        StaffRolesSubview(id: widget.id, scrollCtrl: _scrollCtrl),
      ],
    );
  }
}
