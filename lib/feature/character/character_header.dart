import 'package:flutter/material.dart';
import 'package:otraku/extension/snack_bar_extension.dart';
import 'package:otraku/feature/character/character_model.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/widget/layouts/content_header.dart';
import 'package:otraku/widget/table_list.dart';

class CharacterHeader extends StatelessWidget {
  const CharacterHeader.withTabBar({
    required this.id,
    required this.imageUrl,
    required this.character,
    required TabController this.tabCtrl,
    required void Function() this.scrollToTop,
    required this.toggleFavorite,
  });

  const CharacterHeader.withoutTabBar({
    required this.id,
    required this.imageUrl,
    required this.character,
    required this.toggleFavorite,
  })  : tabCtrl = null,
        scrollToTop = null;

  final int id;
  final String? imageUrl;
  final Character? character;
  final TabController? tabCtrl;
  final void Function()? scrollToTop;
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
      tabBarConfig: tabCtrl != null && scrollToTop != null
          ? (
              tabCtrl: tabCtrl!,
              scrollToTop: scrollToTop!,
              tabs: tabsWithOverview,
            )
          : null,
      trailingTopButtons: [
        if (character != null) _FavoriteButton(character!, toggleFavorite),
      ],
    );
  }

  static const tabsWithoutOverview = [
    Tab(text: 'Anime'),
    Tab(text: 'Manga'),
  ];

  static const tabsWithOverview = [
    Tab(text: 'Overview'),
    ...tabsWithoutOverview,
  ];
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
