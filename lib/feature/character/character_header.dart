import 'package:flutter/material.dart';
import 'package:otraku/extension/snack_bar_extension.dart';
import 'package:otraku/feature/character/character_model.dart';
import 'package:otraku/localizations/gen.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/widget/layout/content_header.dart';
import 'package:otraku/widget/table_list.dart';

class CharacterHeader extends StatelessWidget {
  const CharacterHeader.withTabBar({
    required this.id,
    required this.imageUrl,
    required this.character,
    required TabController this.tabCtrl,
    required void Function() this.scrollToTop,
    required this.toggleFavorite,
    required this.highContrast,
  });

  const CharacterHeader.withoutTabBar({
    required this.id,
    required this.imageUrl,
    required this.character,
    required this.toggleFavorite,
    required this.highContrast,
  }) : tabCtrl = null,
       scrollToTop = null;

  final int id;
  final String? imageUrl;
  final Character? character;
  final TabController? tabCtrl;
  final void Function()? scrollToTop;
  final Future<Object?> Function() toggleFavorite;
  final bool highContrast;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ContentHeader(
      imageUrl: imageUrl ?? character?.imageUrl,
      imageHeightToWidthRatio: Theming.coverHtoWRatio,
      imageHeroTag: id,
      siteUrl: character?.siteUrl,
      title: character?.preferredName,
      details: character != null
          ? [
              TableList([
                (l10n.favorites, character!.favorites.toString()),
                if (character!.gender != null) (l10n.personInfoGender, character!.gender!),
              ], highContrast: highContrast),
            ]
          : const [],
      tabBarConfig: tabCtrl != null && scrollToTop != null
          ? (tabCtrl: tabCtrl!, scrollToTop: scrollToTop!, tabs: tabsWithOverview(l10n))
          : null,
      trailingTopButtons: [
        if (character != null) _FavoriteButton(character!, toggleFavorite, l10n),
      ],
    );
  }

  static List<Tab> tabsWithoutOverview(AppLocalizations l10n) => [
    Tab(text: l10n.mediaTypeAnime),
    Tab(text: l10n.mediaTypeManga),
  ];

  static List<Tab> tabsWithOverview(AppLocalizations l10n) => [
    Tab(text: l10n.overview),
    ...tabsWithoutOverview(l10n),
  ];
}

class _FavoriteButton extends StatefulWidget {
  const _FavoriteButton(this.character, this.toggleFavorite, this.l10n);

  final Character character;
  final Future<Object?> Function() toggleFavorite;
  final AppLocalizations l10n;

  @override
  State<_FavoriteButton> createState() => __FavoriteButtonState();
}

class __FavoriteButtonState extends State<_FavoriteButton> {
  @override
  Widget build(BuildContext context) {
    final character = widget.character;

    return IconButton(
      tooltip: character.isFavorite ? widget.l10n.favoritesRemove : widget.l10n.favoritesAdd,
      icon: character.isFavorite ? const Icon(Icons.favorite) : const Icon(Icons.favorite_border),
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
