import 'package:flutter/material.dart';
import 'package:otraku/extension/snack_bar_extension.dart';
import 'package:otraku/feature/staff/staff_model.dart';
import 'package:otraku/localizations/gen.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/widget/layout/content_header.dart';
import 'package:otraku/widget/table_list.dart';

class StaffHeader extends StatelessWidget {
  const StaffHeader.withTabBar({
    required this.id,
    required this.imageUrl,
    required this.staff,
    required this.tabCtrl,
    required this.scrollToTop,
    required this.toggleFavorite,
    required this.highContrast,
  });

  const StaffHeader.withoutTabBar({
    required this.id,
    required this.imageUrl,
    required this.staff,
    required this.toggleFavorite,
    required this.highContrast,
  }) : tabCtrl = null,
       scrollToTop = null;

  final int id;
  final String? imageUrl;
  final Staff? staff;
  final TabController? tabCtrl;
  final void Function()? scrollToTop;
  final Future<Object?> Function() toggleFavorite;
  final bool highContrast;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ContentHeader(
      imageUrl: imageUrl ?? staff?.imageUrl,
      imageHeightToWidthRatio: Theming.coverHtoWRatio,
      imageHeroTag: id,
      siteUrl: staff?.siteUrl,
      title: staff?.preferredName,
      details: staff != null
          ? [
              TableList([
                (l10n.favorites, staff!.favorites.toString()),
                if (staff!.gender != null) (l10n.personInfoGender, staff!.gender!),
              ], highContrast: highContrast),
            ]
          : const [],
      tabBarConfig: tabCtrl != null && scrollToTop != null
          ? (tabCtrl: tabCtrl!, scrollToTop: scrollToTop!, tabs: tabsWithOverview(l10n))
          : null,
      trailingTopButtons: [if (staff != null) _FavoriteButton(staff!, toggleFavorite, l10n)],
    );
  }

  static List<Tab> tabsWithoutOverview(AppLocalizations l10n) => [
    Tab(text: l10n.characters),
    Tab(text: l10n.roles),
  ];

  static List<Tab> tabsWithOverview(AppLocalizations l10n) => [
    Tab(text: l10n.overview),
    ...tabsWithoutOverview(l10n),
  ];
}

class _FavoriteButton extends StatefulWidget {
  const _FavoriteButton(this.staff, this.toggleFavorite, this.l10n);

  final Staff staff;
  final Future<Object?> Function() toggleFavorite;
  final AppLocalizations l10n;

  @override
  State<_FavoriteButton> createState() => __FavoriteButtonState();
}

class __FavoriteButtonState extends State<_FavoriteButton> {
  @override
  Widget build(BuildContext context) {
    final staff = widget.staff;

    return IconButton(
      tooltip: staff.isFavorite ? widget.l10n.favoritesRemove : widget.l10n.favoritesAdd,
      icon: staff.isFavorite ? const Icon(Icons.favorite) : const Icon(Icons.favorite_border),
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
