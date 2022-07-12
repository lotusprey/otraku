import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/characters/character.dart';
import 'package:otraku/characters/character_info_view.dart';
import 'package:otraku/characters/character_media.dart';
import 'package:otraku/characters/character_media_view.dart';
import 'package:otraku/utils/pagination_controller.dart';
import 'package:otraku/widgets/layouts/page_layout.dart';
import 'package:otraku/widgets/layouts/tab_switcher.dart';
import 'package:otraku/widgets/overlays/dialogs.dart';

class CharacterView extends ConsumerStatefulWidget {
  CharacterView(this.id, this.imageUrl);

  final int id;
  final String? imageUrl;

  @override
  ConsumerState<CharacterView> createState() => _CharacterViewState();
}

class _CharacterViewState extends ConsumerState<CharacterView> {
  late final PaginationController _ctrl;
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    _ctrl = PaginationController(loadMore: () {
      if (_tab == 0) return;
      _tab == 1
          ? ref.read(characterMediaProvider(widget.id)).fetchPage(true)
          : ref.read(characterMediaProvider(widget.id)).fetchPage(false);
    });
  }

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
        if (s.hasError)
          showPopUp(
            context,
            ConfirmationDialog(
              title: 'Could not load character',
              content: s.error.toString(),
            ),
          );
      },
    );

    ref.watch(characterMediaProvider(widget.id).select((_) => null));
    final name = ref.watch(characterProvider(widget.id)).valueOrNull?.name;

    return PageLayout(
      topBar: TopBar(title: name),
      bottomBar: BottomBarIconTabs(
        current: _tab,
        onChanged: (i) => setState(() => _tab = i),
        onSame: (_) => _ctrl.scrollToTop(),
        items: const {
          'Bio': Ionicons.book_outline,
          'Anime': Ionicons.film_outline,
          'Manga': Ionicons.bookmark_outline,
        },
      ),
      child: TabSwitcher(
        current: _tab,
        onChanged: (i) => setState(() => _tab = i),
        children: [
          CharacterInfoView(widget.id, widget.imageUrl, _ctrl),
          CharacterAnimeView(widget.id, _ctrl),
          CharacterMangaView(widget.id, _ctrl),
        ],
      ),
    );
  }
}
