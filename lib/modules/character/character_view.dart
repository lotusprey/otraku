import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/common/widgets/overlays/sheets.dart';
import 'package:otraku/modules/character/character_action_buttons.dart';
import 'package:otraku/modules/character/character_providers.dart';
import 'package:otraku/modules/character/character_info_tab.dart';
import 'package:otraku/common/models/relation.dart';
import 'package:otraku/common/utils/paged_controller.dart';
import 'package:otraku/common/widgets/grids/relation_grid.dart';
import 'package:otraku/common/widgets/layouts/bottom_bar.dart';
import 'package:otraku/common/widgets/layouts/floating_bar.dart';
import 'package:otraku/common/widgets/layouts/scaffolds.dart';
import 'package:otraku/common/widgets/layouts/top_bar.dart';
import 'package:otraku/common/widgets/overlays/dialogs.dart';
import 'package:otraku/common/widgets/paged_view.dart';

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
          showPopUp(
            context,
            ConfirmationDialog(
              title: 'Failed to load character',
              content: s.error.toString(),
            ),
          );
        }
      },
    );

    final character = ref.watch(characterProvider(widget.id));
    ref.watch(characterMediaProvider(widget.id).select((_) => null));
    final onRefresh = () => ref.invalidate(characterMediaProvider(widget.id));

    final topBar = character.valueOrNull != null
        ? TopBar(
            title: character.valueOrNull!.name,
            trailing: [
              TopBarIcon(
                tooltip: 'More',
                icon: Ionicons.ellipsis_horizontal,
                onTap: () => showSheet(
                  context,
                  GradientSheet.link(context, character.valueOrNull!.siteUrl!),
                ),
              ),
            ],
          )
        : const TopBar();

    return PageScaffold(
      bottomBar: BottomNavBar(
        current: _tabCtrl.index,
        onChanged: (i) => _tabCtrl.index = i,
        onSame: (_) => _scrollCtrl.scrollToTop(),
        items: const {
          'Bio': Ionicons.book_outline,
          'Anime': Ionicons.film_outline,
          'Manga': Ionicons.bookmark_outline,
        },
      ),
      child: TabScaffold(
        topBar: topBar,
        floatingBar: FloatingBar(
          scrollCtrl: _scrollCtrl,
          children: [
            if (_tabCtrl.index == 0 && character.hasValue)
              CharacterFavoriteButton(character.valueOrNull!),
            if (_tabCtrl.index > 0) CharacterMediaFilterButton(widget.id),
            if (_tabCtrl.index == 1)
              CharacterLanguageSelectionButton(widget.id),
          ],
        ),
        child: TabBarView(
          controller: _tabCtrl,
          children: [
            CharacterInfoTab(widget.id, widget.imageUrl, _scrollCtrl),
            PagedView<Relation>(
              provider: characterMediaProvider(widget.id).select(
                (s) => s.unwrapPrevious().map(
                      data: (data) => AsyncValue.data(data.value.anime),
                      error: (e) => AsyncValue.error(e, e.stackTrace),
                      loading: (_) => const AsyncValue.loading(),
                    ),
              ),
              onData: (data) {
                return RelationGrid(
                  ref
                      .watch(characterMediaProvider(widget.id))
                      .requireValue
                      .getAnimeAndVoiceActors(),
                );
              },
              scrollCtrl: _scrollCtrl,
              onRefresh: onRefresh,
            ),
            PagedView<Relation>(
              provider: characterMediaProvider(widget.id).select(
                (s) => s.unwrapPrevious().map(
                      data: (data) => AsyncValue.data(data.value.manga),
                      error: (e) => AsyncValue.error(e, e.stackTrace),
                      loading: (_) => const AsyncValue.loading(),
                    ),
              ),
              onData: (data) => SingleRelationGrid(data.items),
              scrollCtrl: _scrollCtrl,
              onRefresh: onRefresh,
            ),
          ],
        ),
      ),
    );
  }
}
