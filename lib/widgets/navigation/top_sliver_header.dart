import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:otraku/enums/themes.dart';
import 'package:otraku/utils/config.dart';
import 'package:otraku/widgets/favourite_button.dart';

class TopSliverHeader extends StatelessWidget {
  final String? text;
  final bool? isFavourite;
  final int? favourites;
  final Future<bool> Function() toggleFavourite;

  TopSliverHeader({
    required this.isFavourite,
    required this.favourites,
    required this.toggleFavourite,
    this.text,
  });

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _Delegate(
        text: text,
        isFavourite: isFavourite,
        favourites: favourites,
        toggleFavourite: toggleFavourite,
      ),
    );
  }
}

class _Delegate implements SliverPersistentHeaderDelegate {
  final String? text;
  final bool? isFavourite;
  final int? favourites;
  final Future<bool> Function() toggleFavourite;

  _Delegate({
    required this.isFavourite,
    required this.favourites,
    required this.toggleFavourite,
    this.text,
  });

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    double shrinkPercentage = shrinkOffset / maxExtent;
    if (shrinkPercentage > 1) shrinkPercentage = 1;

    return Container(
      height: Config.MATERIAL_TAP_TARGET_SIZE,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).backgroundColor,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            padding: const EdgeInsets.all(0),
            constraints: const BoxConstraints(maxWidth: Style.ICON_BIG),
            icon: Icon(
              Icons.close,
              color: Theme.of(context).dividerColor,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          if (text != null && isFavourite != null && favourites != null) ...[
            const SizedBox(width: 15),
            if (shrinkPercentage >= 0.5)
              Expanded(
                child: Opacity(
                  opacity: shrinkPercentage,
                  child: Text(
                    text!,
                    style: Theme.of(context).textTheme.headline5,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            FavouriteButton(
              favourites: favourites!,
              isFavourite: isFavourite!,
              shrinkPercentage: shrinkPercentage,
              onTap: toggleFavourite,
            ),
          ] else
            const SizedBox(),
        ],
      ),
    );
  }

  @override
  double get maxExtent => Config.MATERIAL_TAP_TARGET_SIZE;

  @override
  double get minExtent => Config.MATERIAL_TAP_TARGET_SIZE;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      true;

  @override
  PersistentHeaderShowOnScreenConfiguration? get showOnScreenConfiguration =>
      null;

  @override
  FloatingHeaderSnapConfiguration? get snapConfiguration => null;

  @override
  OverScrollHeaderStretchConfiguration? get stretchConfiguration => null;

  @override
  TickerProvider? get vsync => null;
}
