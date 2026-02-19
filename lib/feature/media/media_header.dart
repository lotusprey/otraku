import 'package:flutter/material.dart';
import 'package:otraku/extension/date_time_extension.dart';
import 'package:otraku/extension/snack_bar_extension.dart';
import 'package:otraku/feature/media/media_models.dart';
import 'package:otraku/localizations/gen.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/widget/layout/content_header.dart';
import 'package:otraku/widget/text_rail.dart';

class MediaHeader extends StatelessWidget {
  const MediaHeader.withTabBar({
    required this.id,
    required this.coverUrl,
    required this.media,
    required TabController this.tabCtrl,
    required void Function() this.scrollToTop,
    required this.toggleFavorite,
  });

  const MediaHeader.withoutTabBar({
    required this.id,
    required this.coverUrl,
    required this.media,
    required this.toggleFavorite,
  }) : tabCtrl = null,
       scrollToTop = null;

  final int id;
  final String? coverUrl;
  final Media? media;
  final TabController? tabCtrl;
  final void Function()? scrollToTop;
  final Future<Object?> Function() toggleFavorite;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textRailItems = <String, bool>{};

    if (media != null) {
      final info = media!.info;

      if (info.isAdult) textRailItems[l10n.mediaAdult] = true;

      if (info.format != null) {
        textRailItems[info.format!.localize(l10n)] = false;
      }

      if (media!.entryEdit.listStatus != null) {
        textRailItems[media!.entryEdit.listStatus!.localize(l10n, info.isAnime)] = false;
      }

      if (info.nextEpisode != null && info.airingAt != null) {
        textRailItems[l10n.mediaEpisodeIn(info.nextEpisode!, info.airingAt!.timeUntil)] = true;
      }

      if (media!.entryEdit.listStatus != null) {
        final progress = media!.entryEdit.progress;
        if (info.nextEpisode != null && info.nextEpisode! - 1 > progress) {
          textRailItems[l10n.mediaEpisodesBehind(info.nextEpisode! - 1 - progress)] = true;
        }
      }
    }

    return ContentHeader(
      bannerUrl: media?.info.banner,
      imageUrl: media?.info.cover ?? coverUrl,
      imageLargeUrl: media?.info.extraLargeCover,
      imageHeightToWidthRatio: Theming.coverHtoWRatio,
      imageHeroTag: id,
      siteUrl: media?.info.siteUrl,
      title: media?.info.preferredTitle,
      details: [TextRail(textRailItems, style: TextTheme.of(context).labelMedium)],
      tabBarConfig: tabCtrl != null && scrollToTop != null
          ? (tabCtrl: tabCtrl!, scrollToTop: scrollToTop!, tabs: tabsWithOverview(l10n))
          : null,
      trailingTopButtons: [if (media != null) _FavoriteButton(media!.info, toggleFavorite, l10n)],
    );
  }

  static List<Tab> tabsWithoutOverview(AppLocalizations l10n) => [
    Tab(text: l10n.related),
    Tab(text: l10n.characters),
    Tab(text: l10n.staff),
    Tab(text: l10n.reviews),
    Tab(text: l10n.threads),
    Tab(text: l10n.followed),
    Tab(text: l10n.activities),
    Tab(text: l10n.recommendations),
    Tab(text: l10n.statistics),
  ];

  static List<Tab> tabsWithOverview(AppLocalizations l10n) => [
    Tab(text: l10n.overview),
    ...tabsWithoutOverview(l10n),
  ];
}

class _FavoriteButton extends StatefulWidget {
  const _FavoriteButton(this.info, this.toggleFavorite, this.l10n);

  final MediaInfo info;
  final Future<Object?> Function() toggleFavorite;
  final AppLocalizations l10n;

  @override
  State<_FavoriteButton> createState() => __FavoriteButtonState();
}

class __FavoriteButtonState extends State<_FavoriteButton> {
  @override
  Widget build(BuildContext context) {
    final info = widget.info;

    return IconButton(
      tooltip: info.isFavorite ? widget.l10n.favoritesRemove : widget.l10n.favoritesAdd,
      icon: info.isFavorite ? const Icon(Icons.favorite) : const Icon(Icons.favorite_border),
      onPressed: () async {
        setState(() => info.isFavorite = !info.isFavorite);

        final err = await widget.toggleFavorite();
        if (err == null) return;

        setState(() => info.isFavorite = !info.isFavorite);
        if (context.mounted) SnackBarExtension.show(context, err.toString());
      },
    );
  }
}
