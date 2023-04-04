import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/character/character_providers.dart';
import 'package:otraku/character/character_info_tab.dart';
import 'package:otraku/character/character_media_tab.dart';
import 'package:otraku/utils/paged_controller.dart';
import 'package:otraku/widgets/layouts/bottom_bar.dart';
import 'package:otraku/widgets/layouts/scaffolds.dart';
import 'package:otraku/widgets/layouts/direct_page_view.dart';
import 'package:otraku/widgets/layouts/top_bar.dart';
import 'package:otraku/widgets/overlays/dialogs.dart';

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
        ? ref.read(characterMediaProvider(widget.id)).fetchPage(true)
        : ref.read(characterMediaProvider(widget.id)).fetchPage(false);
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

    ref.watch(characterMediaProvider(widget.id).select((_) => null));
    final name = ref.watch(characterProvider(widget.id)).valueOrNull?.name;
    final topBar = TopBar(title: name);

    return PageScaffold(
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
      child: DirectPageView(
        current: _tab,
        onChanged: (i) => setState(() => _tab = i),
        children: [
          CharacterInfoTab(widget.id, widget.imageUrl, _ctrl, topBar),
          CharacterAnimeTab(widget.id, _ctrl, topBar),
          CharacterMangaTab(widget.id, _ctrl, topBar),
        ],
      ),
    );
  }
}
