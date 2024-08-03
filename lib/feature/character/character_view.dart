import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/extension/scaffold_extension.dart';
import 'package:otraku/feature/character/character_header.dart';
import 'package:otraku/feature/character/character_model.dart';
import 'package:otraku/feature/character/character_floating_actions.dart';
import 'package:otraku/feature/character/character_anime_view.dart';
import 'package:otraku/feature/character/character_manga_view.dart';
import 'package:otraku/feature/character/character_provider.dart';
import 'package:otraku/feature/character/character_overview_view.dart';
import 'package:otraku/util/paged_controller.dart';
import 'package:otraku/widget/loaders/loaders.dart';
import 'package:otraku/widget/overlays/dialogs.dart';

class CharacterView extends ConsumerStatefulWidget {
  const CharacterView(this.id, this.imageUrl);

  final int id;
  final String? imageUrl;

  @override
  ConsumerState<CharacterView> createState() => _CharacterViewState();
}

class _CharacterViewState extends ConsumerState<CharacterView>
    with SingleTickerProviderStateMixin {
  late final _tabCtrl = TabController(length: 3, vsync: this);
  late final _scrollCtrl = PagedController(loadMore: () {
    if (_tabCtrl.index == 0) return;
    _tabCtrl.index == 1
        ? ref.read(characterMediaProvider(widget.id).notifier).fetch(true)
        : ref.read(characterMediaProvider(widget.id).notifier).fetch(false);
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
      characterProvider(widget.id),
      (_, s) {
        if (s.hasError) {
          showDialog(
            context: context,
            builder: (context) => ConfirmationDialog(
              title: 'Failed to load character',
              content: s.error.toString(),
            ),
          );
        }
      },
    );

    final character = ref.watch(characterProvider(widget.id));
    final mediaQuery = MediaQuery.of(context);

    return ScaffoldExtension.expanded(
      context: context,
      floatingActionConfig: (
        scrollCtrl: _scrollCtrl,
        actions: [
          if (_tabCtrl.index == 0 && character.hasValue)
            CharacterFavoriteButton(
              character.valueOrNull!,
              ref.read(characterProvider(widget.id).notifier).toggleFavorite,
            ),
          if (_tabCtrl.index > 0) CharacterMediaFilterButton(widget.id, ref),
          if (_tabCtrl.index == 1) CharacterLanguageSelectionButton(widget.id),
        ],
      ),
      child: NestedScrollView(
        controller: _scrollCtrl,
        headerSliverBuilder: (context, _) => [
          CharacterHeader(
            id: widget.id,
            imageUrl: widget.imageUrl,
            character: character.valueOrNull,
            tabCtrl: _tabCtrl,
            scrollToTop: _scrollCtrl.scrollToTop,
          ),
        ],
        body: MediaQuery(
          data: mediaQuery.copyWith(
            padding: mediaQuery.padding.copyWith(top: 0),
          ),
          child: character.unwrapPrevious().when(
                loading: () => const Center(child: Loader()),
                error: (_, __) => const Center(
                  child: Text('Failed to load character'),
                ),
                data: (character) => _CharacterViewContent(
                  widget.id,
                  character,
                  _tabCtrl,
                ),
              ),
        ),
      ),
    );
  }
}

class _CharacterViewContent extends ConsumerStatefulWidget {
  const _CharacterViewContent(this.id, this.character, this.tabCtrl);

  final int id;
  final Character character;
  final TabController tabCtrl;

  @override
  ConsumerState<_CharacterViewContent> createState() =>
      __CharacterViewContentState();
}

class __CharacterViewContentState extends ConsumerState<_CharacterViewContent> {
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
        .read(characterMediaProvider(widget.id).notifier)
        .fetch(widget.tabCtrl.index == 1);
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(characterMediaProvider(widget.id).select((_) => null));

    return TabBarView(
      controller: widget.tabCtrl,
      children: [
        CharacterOverviewSubview(
          character: widget.character,
          scrollCtrl: _scrollCtrl,
          invalidate: () => ref.invalidate(characterProvider(widget.id)),
        ),
        CharacterAnimeSubview(id: widget.id, scrollCtrl: _scrollCtrl),
        CharacterMangaSubview(id: widget.id, scrollCtrl: _scrollCtrl),
      ],
    );
  }
}
