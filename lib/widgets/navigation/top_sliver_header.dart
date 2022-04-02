import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:otraku/constants/consts.dart';
import 'package:otraku/widgets/favourite_button.dart';
import 'package:otraku/widgets/navigation/app_bars.dart';

// This is to be merged into SliverShadowAppBar, after
// changes in how favouriting is handled take place.
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
      height: Consts.TAP_TARGET_SIZE,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.background,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          AppBarIcon(
            tooltip: 'Close',
            icon: Icons.close_rounded,
            onTap: () => Navigator.pop(context),
          ),
          if (text != null && isFavourite != null && favourites != null) ...[
            Expanded(
              child: shrinkPercentage >= 0.5
                  ? Opacity(
                      opacity: shrinkPercentage,
                      child: Text(
                        text!,
                        style: Theme.of(context).textTheme.headline2,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    )
                  : const SizedBox(),
            ),
            FavouriteButton(
              favourites: favourites!,
              isFavourite: isFavourite!,
              shrinkPercentage: shrinkPercentage,
              onTap: toggleFavourite,
            ),
          ],
        ],
      ),
    );
  }

  @override
  double get maxExtent => Consts.TAP_TARGET_SIZE;

  @override
  double get minExtent => Consts.TAP_TARGET_SIZE;

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
