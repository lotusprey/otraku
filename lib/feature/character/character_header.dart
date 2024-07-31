import 'package:flutter/material.dart';
import 'package:otraku/feature/character/character_model.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/widget/layouts/content_header.dart';
import 'package:otraku/widget/table_list.dart';

class CharacterHeader extends StatelessWidget {
  const CharacterHeader({
    required this.id,
    required this.imageUrl,
    required this.character,
    required this.tabCtrl,
    required this.scrollToTop,
  });

  final int id;
  final String? imageUrl;
  final Character? character;
  final TabController tabCtrl;
  final void Function() scrollToTop;

  @override
  Widget build(BuildContext context) {
    return ContentHeader(
      imageUrl: imageUrl ?? character?.imageUrl,
      imageHeightToWidthRatio: Theming.coverHtoWRatio,
      imageHeroTag: id,
      siteUrl: character?.siteUrl,
      title: character?.preferredName,
      details: character != null
          ? TableList([
              ('Favorites', character!.favorites.toString()),
              if (character!.gender != null) ('Gender', character!.gender!),
            ])
          : null,
      tabBarConfig: (
        tabCtrl: tabCtrl,
        scrollToTop: scrollToTop,
        tabs: const [
          Tab(text: 'Overview'),
          Tab(text: 'Anime'),
          Tab(text: 'Manga'),
        ],
      ),
    );
  }
}
