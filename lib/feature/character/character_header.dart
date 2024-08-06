import 'package:flutter/material.dart';
import 'package:otraku/extension/snack_bar_extension.dart';
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
    required this.toggleFavorite,
  });

  final int id;
  final String? imageUrl;
  final Character? character;
  final TabController tabCtrl;
  final void Function() scrollToTop;
  final Future<Object?> Function() toggleFavorite;

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
      trailingTopButtons: [
        if (character != null) _FavoriteButton(character!, toggleFavorite),
      ],
    );
  }
}

class _FavoriteButton extends StatefulWidget {
  const _FavoriteButton(this.character, this.toggleFavorite);

  final Character character;
  final Future<Object?> Function() toggleFavorite;

  @override
  State<_FavoriteButton> createState() => __FavoriteButtonState();
}

class __FavoriteButtonState extends State<_FavoriteButton> {
  @override
  Widget build(BuildContext context) {
    final character = widget.character;

    return IconButton(
      tooltip: character.isFavorite ? 'Unfavourite' : 'Favourite',
      icon: character.isFavorite
          ? const Icon(Icons.favorite)
          : const Icon(Icons.favorite_border),
      onPressed: () async {
        setState(() => character.isFavorite = !character.isFavorite);

        final err = await widget.toggleFavorite();
        if (err == null) return;

        setState(() => character.isFavorite = !character.isFavorite);
        if (context.mounted) SnackBarExtension.show(context, err.toString());
      },
    );
  }
}
