import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/character/character_action_buttons.dart';
import 'package:otraku/character/character_providers.dart';
import 'package:otraku/character/character_info_tab.dart';
import 'package:otraku/common/relation.dart';
import 'package:otraku/utils/paged_controller.dart';
import 'package:otraku/widgets/grids/relation_grid.dart';
import 'package:otraku/widgets/layouts/bottom_bar.dart';
import 'package:otraku/widgets/layouts/floating_bar.dart';
import 'package:otraku/widgets/layouts/scaffolds.dart';
import 'package:otraku/widgets/layouts/direct_page_view.dart';
import 'package:otraku/widgets/layouts/top_bar.dart';
import 'package:otraku/widgets/overlays/dialogs.dart';
import 'package:otraku/widgets/paged_view.dart';

class CharacterView extends ConsumerStatefulWidget {
  const CharacterView(this.id, this.imageUrl);

  final int id;
  final String? imageUrl;

  @override
  ConsumerState<CharacterView> createState() => _CharacterViewState();
}

class _CharacterViewState extends ConsumerState<CharacterView> {
  int _tab = 0;
  late final _ctrl = PagedController(loadMore: () {
    if (_tab == 0) return;
    _tab == 1
        ? ref.read(characterMediaProvider(widget.id).notifier).fetch(true)
        : ref.read(characterMediaProvider(widget.id).notifier).fetch(false);
  });

  @override
  void dispose() {
    _ctrl.dispose();
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

    return PageScaffold(
      bottomBar: BottomNavBar(
        current: _tab,
        onChanged: (i) => setState(() => _tab = i),
        onSame: (_) => _ctrl.scrollToTop(),
        items: const {
          'Bio': Ionicons.book_outline,
          'Anime': Ionicons.film_outline,
          'Manga': Ionicons.bookmark_outline,
        },
      ),
      child: TabScaffold(
        topBar: TopBar(
          title: character.valueOrNull?.name,
        ),
        floatingBar: FloatingBar(
          scrollCtrl: _ctrl,
          children: [
            if (_tab == 0 && character.hasValue)
              CharacterFavoriteButton(character.valueOrNull!),
            if (_tab > 0) CharacterMediaFilterButton(widget.id),
            if (_tab == 1) CharacterLanguageSelectionButton(widget.id),
          ],
        ),
        child: DirectPageView(
          current: _tab,
          onChanged: (i) => setState(() => _tab = i),
          children: [
            CharacterInfoTab(widget.id, widget.imageUrl, _ctrl),
            PagedView<Relation>(
              provider:
                  characterMediaProvider(widget.id).select((s) => s.anime),
              onData: (data) {
                final anime = <Relation>[];
                final voiceActors = <Relation?>[];
                ref
                    .watch(characterMediaProvider(widget.id))
                    .getAnimeAndVoiceActors(anime, voiceActors);

                return RelationGrid(items: anime, connections: voiceActors);
              },
              scrollCtrl: _ctrl,
              onRefresh: onRefresh,
            ),
            PagedView<Relation>(
              provider:
                  characterMediaProvider(widget.id).select((s) => s.manga),
              onData: (data) => RelationGrid(items: data.items),
              scrollCtrl: _ctrl,
              onRefresh: onRefresh,
            ),
          ],
        ),
      ),
    );
  }
}
