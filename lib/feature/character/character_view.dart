import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/extension/scaffold_extension.dart';
import 'package:otraku/widget/overlays/sheets.dart';
import 'package:otraku/feature/character/character_floating_actions.dart';
import 'package:otraku/feature/character/character_anime_view.dart';
import 'package:otraku/feature/character/character_manga_view.dart';
import 'package:otraku/feature/character/character_provider.dart';
import 'package:otraku/feature/character/character_overview_view.dart';
import 'package:otraku/util/paged_controller.dart';
import 'package:otraku/widget/layouts/bottom_bar.dart';
import 'package:otraku/widget/layouts/top_bar.dart';
import 'package:otraku/widget/overlays/dialogs.dart';
import 'package:otraku/widget/swipe_switcher.dart';

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
    ref.watch(characterMediaProvider(widget.id).select((_) => null));

    final topBar = character.valueOrNull != null
        ? TopBar(
            title: character.valueOrNull!.name,
            trailing: [
              IconButton(
                tooltip: 'More',
                icon: const Icon(Ionicons.ellipsis_horizontal),
                onPressed: () => showSheet(
                  context,
                  SimpleSheet.link(context, character.valueOrNull!.siteUrl!),
                ),
              ),
            ],
          )
        : const TopBar();

    return ScaffoldExtension.expanded(
      topBar: topBar,
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
      bottomBar: BottomNavBar(
        current: _tabCtrl.index,
        onChanged: (i) => _tabCtrl.index = i,
        onSame: (_) => _scrollCtrl.scrollToTop(),
        items: const {
          'Overview': Ionicons.information_outline,
          'Anime': Ionicons.film_outline,
          'Manga': Ionicons.book_outline,
        },
      ),
      child: SwipeSwitcher(
        index: _tabCtrl.index,
        onChanged: (index) => _tabCtrl.index = index,
        children: [
          CharacterOverviewSubview(
            id: widget.id,
            scrollCtrl: _scrollCtrl,
            imageUrl: widget.imageUrl,
          ),
          CharacterAnimeSubview(id: widget.id, scrollCtrl: _scrollCtrl),
          CharacterMangaSubview(id: widget.id, scrollCtrl: _scrollCtrl),
        ],
      ),
    );
  }
}
