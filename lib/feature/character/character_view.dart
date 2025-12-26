import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/extension/scroll_controller_extension.dart';
import 'package:otraku/extension/snack_bar_extension.dart';
import 'package:otraku/feature/character/character_header.dart';
import 'package:otraku/feature/character/character_model.dart';
import 'package:otraku/feature/character/character_floating_actions.dart';
import 'package:otraku/feature/character/character_anime_view.dart';
import 'package:otraku/feature/character/character_manga_view.dart';
import 'package:otraku/feature/character/character_provider.dart';
import 'package:otraku/feature/character/character_overview_view.dart';
import 'package:otraku/feature/viewer/persistence_provider.dart';
import 'package:otraku/util/paged_controller.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/widget/layout/adaptive_scaffold.dart';
import 'package:otraku/widget/layout/constrained_view.dart';
import 'package:otraku/widget/layout/hiding_floating_action_button.dart';
import 'package:otraku/widget/layout/dual_pane_with_tab_bar.dart';
import 'package:otraku/widget/loaders.dart';

class CharacterView extends ConsumerStatefulWidget {
  const CharacterView(this.id, this.imageUrl);

  final int id;
  final String? imageUrl;

  @override
  ConsumerState<CharacterView> createState() => _CharacterViewState();
}

class _CharacterViewState extends ConsumerState<CharacterView> {
  final _scrollCtrl = PagedController(loadMore: () {});

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue>(characterProvider(widget.id), (_, s) {
      if (s.hasError) {
        SnackBarExtension.show(context, 'Failed to load character: ${s.error}');
      }
    });

    final character = ref.watch(characterProvider(widget.id));
    final options = ref.watch(persistenceProvider.select((s) => s.options));

    final toggleFavorite = () => ref.read(characterProvider(widget.id).notifier).toggleFavorite();

    return AdaptiveScaffold(
      floatingAction: HidingFloatingActionButton(
        key: const Key('filter'),
        scrollCtrl: _scrollCtrl,
        child: CharacterMediaFilterButton(widget.id, ref),
      ),
      child: switch (Theming.of(context).formFactor) {
        .phone => _CompactView(
          id: widget.id,
          imageUrl: widget.imageUrl,
          ref: ref,
          highContrast: options.highContrast,
          character: character,
          scrollCtrl: _scrollCtrl,
          toggleFavorite: toggleFavorite,
        ),
        .tablet => _LargeView(
          id: widget.id,
          imageUrl: widget.imageUrl,
          ref: ref,
          highContrast: options.highContrast,
          character: character,
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
    required this.highContrast,
    required this.character,
    required this.scrollCtrl,
    required this.toggleFavorite,
  });

  final int id;
  final String? imageUrl;
  final WidgetRef ref;
  final bool highContrast;
  final AsyncValue<Character> character;
  final PagedController scrollCtrl;
  final Future<Object?> Function() toggleFavorite;

  @override
  State<_CompactView> createState() => _CompactViewState();
}

class _CompactViewState extends State<_CompactView> with SingleTickerProviderStateMixin {
  late final _tabCtrl = TabController(length: CharacterHeader.tabsWithOverview.length, vsync: this);

  @override
  void initState() {
    super.initState();
    widget.scrollCtrl.loadMore = () {
      if (_tabCtrl.index > 0) {
        widget.ref.read(characterMediaProvider(widget.id).notifier).fetch(_tabCtrl.index == 1);
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

    final header = CharacterHeader.withTabBar(
      id: widget.id,
      imageUrl: widget.imageUrl,
      character: widget.character.value,
      tabCtrl: _tabCtrl,
      scrollToTop: widget.scrollCtrl.scrollToTop,
      toggleFavorite: widget.toggleFavorite,
      highContrast: widget.highContrast,
    );

    return NestedScrollView(
      controller: widget.scrollCtrl,
      headerSliverBuilder: (context, _) => [header],
      body: MediaQuery(
        data: mediaQuery.copyWith(padding: mediaQuery.padding.copyWith(top: 0)),
        child: widget.character.unwrapPrevious().when(
          loading: () => const Center(child: Loader()),
          error: (_, _) => const Center(child: Text('Failed to load character')),
          data: (data) => _CharacterTabs.withOverview(
            id: widget.id,
            character: data,
            tabCtrl: _tabCtrl,
            highContrast: widget.highContrast,
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
    required this.highContrast,
    required this.character,
    required this.scrollCtrl,
    required this.toggleFavorite,
  });

  final int id;
  final String? imageUrl;
  final WidgetRef ref;
  final bool highContrast;
  final AsyncValue<Character> character;
  final PagedController scrollCtrl;
  final Future<Object?> Function() toggleFavorite;

  @override
  State<_LargeView> createState() => _LargeViewState();
}

class _LargeViewState extends State<_LargeView> with SingleTickerProviderStateMixin {
  late final _tabCtrl = TabController(
    length: CharacterHeader.tabsWithoutOverview.length,
    vsync: this,
  );

  @override
  void initState() {
    super.initState();
    widget.scrollCtrl.loadMore = () {
      widget.ref.read(characterMediaProvider(widget.id).notifier).fetch(_tabCtrl.index == 0);
    };
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final header = CharacterHeader.withoutTabBar(
      id: widget.id,
      imageUrl: widget.imageUrl,
      character: widget.character.value,
      toggleFavorite: widget.toggleFavorite,
      highContrast: widget.highContrast,
    );

    return DualPaneWithTabBar(
      tabCtrl: _tabCtrl,
      scrollToTop: widget.scrollCtrl.scrollToTop,
      tabs: CharacterHeader.tabsWithoutOverview,
      leftPane: widget.character.unwrapPrevious().when(
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
            const SliverFillRemaining(child: Center(child: Text('Failed to load character'))),
          ],
        ),
        data: (data) => CharacterOverviewSubview.withHeader(
          character: data,
          header: header,
          highContrast: widget.highContrast,
          invalidate: () => widget.ref.invalidate(characterProvider(widget.id)),
        ),
      ),
      rightPane: widget.character.unwrapPrevious().maybeWhen(
        data: (data) => _CharacterTabs.withoutOverview(
          id: widget.id,
          character: data,
          tabCtrl: _tabCtrl,
          scrollCtrl: widget.scrollCtrl,
          highContrast: widget.highContrast,
        ),
        orElse: () => const SizedBox(),
      ),
    );
  }
}

class _CharacterTabs extends ConsumerStatefulWidget {
  const _CharacterTabs.withOverview({
    required this.id,
    required this.character,
    required this.tabCtrl,
    required this.highContrast,
  }) : withOverview = true,
       scrollCtrl = null;

  const _CharacterTabs.withoutOverview({
    required this.id,
    required this.character,
    required this.tabCtrl,
    required this.highContrast,
    required ScrollController this.scrollCtrl,
  }) : withOverview = false;

  final int id;
  final Character character;
  final TabController tabCtrl;
  final ScrollController? scrollCtrl;
  final bool highContrast;
  final bool withOverview;

  @override
  ConsumerState<_CharacterTabs> createState() => __CharacterViewContentState();
}

class __CharacterViewContentState extends ConsumerState<_CharacterTabs> {
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

    if (index > 0) {
      ref.read(characterMediaProvider(widget.id).notifier).fetch(index == 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(characterMediaProvider(widget.id).select((_) => null));

    final options = ref.watch(persistenceProvider.select((s) => s.options));

    return TabBarView(
      controller: widget.tabCtrl,
      children: [
        if (widget.withOverview)
          ConstrainedView(
            padded: false,
            child: CharacterOverviewSubview.asFragment(
              character: widget.character,
              scrollCtrl: _scrollCtrl,
              invalidate: () => ref.invalidate(characterProvider(widget.id)),
              highContrast: widget.highContrast,
            ),
          ),
        CharacterAnimeSubview(
          id: widget.id,
          scrollCtrl: _scrollCtrl,
          highContrast: options.highContrast,
        ),
        CharacterMangaSubview(
          id: widget.id,
          scrollCtrl: _scrollCtrl,
          highContrast: options.highContrast,
        ),
      ],
    );
  }
}
