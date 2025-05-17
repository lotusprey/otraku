import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/extension/scroll_controller_extension.dart';
import 'package:otraku/extension/snack_bar_extension.dart';
import 'package:otraku/feature/staff/staff_header.dart';
import 'package:otraku/feature/staff/staff_model.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/widget/layout/adaptive_scaffold.dart';
import 'package:otraku/widget/layout/constrained_view.dart';
import 'package:otraku/widget/layout/hiding_floating_action_button.dart';
import 'package:otraku/widget/layout/dual_pane_with_tab_bar.dart';
import 'package:otraku/widget/loaders.dart';
import 'package:otraku/feature/staff/staff_floating_actions.dart';
import 'package:otraku/feature/staff/staff_characters_view.dart';
import 'package:otraku/feature/staff/staff_overview_view.dart';
import 'package:otraku/feature/staff/staff_provider.dart';
import 'package:otraku/util/paged_controller.dart';
import 'package:otraku/feature/staff/staff_roles_view.dart';

class StaffView extends ConsumerStatefulWidget {
  const StaffView(this.id, this.imageUrl);

  final int id;
  final String? imageUrl;

  @override
  ConsumerState<StaffView> createState() => _StaffViewState();
}

class _StaffViewState extends ConsumerState<StaffView> {
  late final _scrollCtrl = PagedController(loadMore: () {});

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue>(
      staffProvider(widget.id),
      (_, s) {
        if (s.hasError) {
          SnackBarExtension.show(
            context,
            'Failed to load staff: ${s.error}',
          );
        }
      },
    );

    final staff = ref.watch(staffProvider(widget.id));

    final toggleFavorite =
        ref.read(staffProvider(widget.id).notifier).toggleFavorite;

    return AdaptiveScaffold(
      floatingAction: HidingFloatingActionButton(
        key: const Key('filter'),
        scrollCtrl: _scrollCtrl,
        child: StaffFilterButton(widget.id, ref),
      ),
      child: switch (Theming.of(context).formFactor) {
        FormFactor.phone => _CompactView(
            id: widget.id,
            imageUrl: widget.imageUrl,
            ref: ref,
            staff: staff,
            scrollCtrl: _scrollCtrl,
            toggleFavorite: toggleFavorite,
          ),
        FormFactor.tablet => _LargeView(
            id: widget.id,
            imageUrl: widget.imageUrl,
            ref: ref,
            staff: staff,
            scrollCtrl: _scrollCtrl,
            toggleFavorite: toggleFavorite,
          ),
      },
    );
  }
}

class _CompactView extends StatefulWidget {
  const _CompactView({
    required this.id,
    required this.imageUrl,
    required this.ref,
    required this.staff,
    required this.scrollCtrl,
    required this.toggleFavorite,
  });

  final int id;
  final String? imageUrl;
  final WidgetRef ref;
  final AsyncValue<Staff> staff;
  final PagedController scrollCtrl;
  final Future<Object?> Function() toggleFavorite;

  @override
  State<_CompactView> createState() => _CompactViewState();
}

class _CompactViewState extends State<_CompactView>
    with SingleTickerProviderStateMixin {
  late final _tabCtrl = TabController(
    length: StaffHeader.tabsWithOverview.length,
    vsync: this,
  );

  @override
  void initState() {
    super.initState();
    widget.scrollCtrl.loadMore = () {
      if (_tabCtrl.index > 0) {
        widget.ref
            .read(staffRelationsProvider(widget.id).notifier)
            .fetch(_tabCtrl.index == 1);
      }
    };
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    final header = StaffHeader.withTabBar(
      id: widget.id,
      imageUrl: widget.imageUrl,
      staff: widget.staff.valueOrNull,
      tabCtrl: _tabCtrl,
      scrollToTop: widget.scrollCtrl.scrollToTop,
      toggleFavorite: widget.toggleFavorite,
    );

    return NestedScrollView(
      controller: widget.scrollCtrl,
      headerSliverBuilder: (context, _) => [header],
      body: MediaQuery(
        data: mediaQuery.copyWith(
          padding: mediaQuery.padding.copyWith(top: 0),
        ),
        child: widget.staff.unwrapPrevious().when(
              loading: () => const Center(child: Loader()),
              error: (_, __) => const Center(
                child: Text('Failed to load staff'),
              ),
              data: (data) => _StaffTabs.withOverview(
                id: widget.id,
                staff: data,
                tabCtrl: _tabCtrl,
              ),
            ),
      ),
    );
  }
}

class _LargeView extends StatefulWidget {
  const _LargeView({
    required this.id,
    required this.imageUrl,
    required this.ref,
    required this.staff,
    required this.scrollCtrl,
    required this.toggleFavorite,
  });

  final int id;
  final String? imageUrl;
  final WidgetRef ref;
  final AsyncValue<Staff> staff;
  final PagedController scrollCtrl;
  final Future<Object?> Function() toggleFavorite;

  @override
  State<_LargeView> createState() => _LargeViewState();
}

class _LargeViewState extends State<_LargeView>
    with SingleTickerProviderStateMixin {
  late final _tabCtrl = TabController(
    length: StaffHeader.tabsWithoutOverview.length,
    vsync: this,
  );

  @override
  void initState() {
    super.initState();
    widget.scrollCtrl.loadMore = () {
      widget.ref
          .read(staffRelationsProvider(widget.id).notifier)
          .fetch(_tabCtrl.index == 0);
    };
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final header = StaffHeader.withoutTabBar(
      id: widget.id,
      imageUrl: widget.imageUrl,
      staff: widget.staff.valueOrNull,
      toggleFavorite: widget.toggleFavorite,
    );

    return DualPaneWithTabBar(
      tabCtrl: _tabCtrl,
      scrollToTop: widget.scrollCtrl.scrollToTop,
      tabs: StaffHeader.tabsWithoutOverview,
      leftPane: widget.staff.unwrapPrevious().when(
            loading: () => CustomScrollView(
              physics: Theming.bouncyPhysics,
              slivers: [
                header,
                const SliverFillRemaining(
                  child: Center(child: Loader()),
                ),
              ],
            ),
            error: (_, __) => CustomScrollView(
              physics: Theming.bouncyPhysics,
              slivers: [
                header,
                const SliverFillRemaining(
                  child: Center(
                    child: Text('Failed to load staff'),
                  ),
                ),
              ],
            ),
            data: (data) => StaffOverviewSubview.withHeader(
              staff: data,
              header: header,
              invalidate: () => widget.ref.invalidate(
                staffProvider(widget.id),
              ),
            ),
          ),
      rightPane: widget.staff.unwrapPrevious().maybeWhen(
            data: (data) => _StaffTabs.withoutOverview(
              id: widget.id,
              staff: data,
              tabCtrl: _tabCtrl,
              scrollCtrl: widget.scrollCtrl,
            ),
            orElse: () => const SizedBox(),
          ),
    );
  }
}

class _StaffTabs extends ConsumerStatefulWidget {
  const _StaffTabs.withOverview({
    required this.id,
    required this.staff,
    required this.tabCtrl,
  })  : withOverview = true,
        scrollCtrl = null;

  const _StaffTabs.withoutOverview({
    required this.id,
    required this.staff,
    required this.tabCtrl,
    required ScrollController this.scrollCtrl,
  }) : withOverview = false;

  final int id;
  final Staff staff;
  final TabController tabCtrl;
  final ScrollController? scrollCtrl;
  final bool withOverview;

  @override
  ConsumerState<_StaffTabs> createState() => __StaffViewContentState();
}

class __StaffViewContentState extends ConsumerState<_StaffTabs> {
  late final ScrollController _scrollCtrl;
  double _lastMaxExtent = 0;

  @override
  void initState() {
    super.initState();
    _scrollCtrl = widget.scrollCtrl ??
        context
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
    final index =
        widget.withOverview ? widget.tabCtrl.index : widget.tabCtrl.index + 1;

    if (index > 0) {
      ref.read(staffRelationsProvider(widget.id).notifier).fetch(index == 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(staffRelationsProvider(widget.id).select((_) => null));

    return TabBarView(
      controller: widget.tabCtrl,
      children: [
        if (widget.withOverview)
          ConstrainedView(
            padded: false,
            child: StaffOverviewSubview.asFragment(
              staff: widget.staff,
              scrollCtrl: _scrollCtrl,
              invalidate: () => ref.invalidate(staffProvider(widget.id)),
            ),
          ),
        StaffCharactersSubview(id: widget.id, scrollCtrl: _scrollCtrl),
        StaffRolesSubview(id: widget.id, scrollCtrl: _scrollCtrl),
      ],
    );
  }
}
