import 'package:flutter/material.dart';
import 'package:otraku/extension/snack_bar_extension.dart';
import 'package:otraku/feature/studio/studio_model.dart';
import 'package:otraku/widget/layout/content_header.dart';

class StudioHeader extends StatelessWidget {
  const StudioHeader({
    required this.id,
    required this.name,
    required this.studio,
    required this.toggleFavorite,
  });

  final int id;
  final String? name;
  final Studio? studio;
  final Future<Object?> Function() toggleFavorite;

  @override
  Widget build(BuildContext context) {
    final name = studio?.name ?? this.name;

    return CustomContentHeader(
      title: name,
      siteUrl: studio?.siteUrl,
      trailingTopButtons: studio != null
          ? [_FavoriteButton(studio!, toggleFavorite)]
          : const [],
      content: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (name != null)
              Flexible(
                child: GestureDetector(
                  onTap: () => SnackBarExtension.copy(context, name),
                  child: Hero(
                    tag: id,
                    child: Text(
                      name,
                      overflow: TextOverflow.fade,
                      textAlign: TextAlign.center,
                      style: TextTheme.of(context).titleLarge,
                    ),
                  ),
                ),
              ),
            if (studio != null)
              Flexible(
                child: Text(
                  '${studio!.favorites} Favorites',
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _FavoriteButton extends StatefulWidget {
  const _FavoriteButton(this.studio, this.toggleFavorite);

  final Studio studio;
  final Future<Object?> Function() toggleFavorite;

  @override
  State<_FavoriteButton> createState() => __FavoriteButtonState();
}

class __FavoriteButtonState extends State<_FavoriteButton> {
  @override
  Widget build(BuildContext context) {
    final studio = widget.studio;

    return IconButton(
      tooltip: studio.isFavorite ? 'Unfavourite' : 'Favourite',
      icon: studio.isFavorite
          ? const Icon(Icons.favorite)
          : const Icon(Icons.favorite_border),
      onPressed: () async {
        setState(() => studio.isFavorite = !studio.isFavorite);

        final err = await widget.toggleFavorite();
        if (err == null) return;

        setState(() => studio.isFavorite = !studio.isFavorite);
        if (context.mounted) SnackBarExtension.show(context, err.toString());
      },
    );
  }
}
