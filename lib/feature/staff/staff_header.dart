import 'package:flutter/material.dart';
import 'package:otraku/extension/snack_bar_extension.dart';
import 'package:otraku/feature/staff/staff_model.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/widget/layouts/content_header.dart';
import 'package:otraku/widget/table_list.dart';

class StaffHeader extends StatelessWidget {
  const StaffHeader({
    required this.id,
    required this.imageUrl,
    required this.staff,
    required this.tabCtrl,
    required this.scrollToTop,
    required this.toggleFavorite,
  });

  final int id;
  final String? imageUrl;
  final Staff? staff;
  final TabController tabCtrl;
  final void Function() scrollToTop;
  final Future<Object?> Function() toggleFavorite;

  @override
  Widget build(BuildContext context) {
    return ContentHeader(
      imageUrl: imageUrl ?? staff?.imageUrl,
      imageHeightToWidthRatio: Theming.coverHtoWRatio,
      imageHeroTag: id,
      siteUrl: staff?.siteUrl,
      title: staff?.preferredName,
      details: staff != null
          ? TableList([
              ('Favorites', staff!.favorites.toString()),
              if (staff!.gender != null) ('Gender', staff!.gender!),
            ])
          : null,
      tabBarConfig: (
        tabCtrl: tabCtrl,
        scrollToTop: scrollToTop,
        tabs: const [
          Tab(text: 'Overview'),
          Tab(text: 'Characters'),
          Tab(text: 'Roles'),
        ],
      ),
      trailingTopButtons: [
        if (staff != null) _FavoriteButton(staff!, toggleFavorite),
      ],
    );
  }
}

class _FavoriteButton extends StatefulWidget {
  const _FavoriteButton(this.staff, this.toggleFavorite);

  final Staff staff;
  final Future<Object?> Function() toggleFavorite;

  @override
  State<_FavoriteButton> createState() => __FavoriteButtonState();
}

class __FavoriteButtonState extends State<_FavoriteButton> {
  @override
  Widget build(BuildContext context) {
    final staff = widget.staff;

    return IconButton(
      tooltip: staff.isFavorite ? 'Unfavourite' : 'Favourite',
      icon: staff.isFavorite
          ? const Icon(Icons.favorite)
          : const Icon(Icons.favorite_border),
      onPressed: () async {
        setState(() => staff.isFavorite = !staff.isFavorite);

        final err = await widget.toggleFavorite();
        if (err == null) return;

        setState(() => staff.isFavorite = !staff.isFavorite);
        if (context.mounted) SnackBarExtension.show(context, err.toString());
      },
    );
  }
}
