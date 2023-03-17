import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/utils/consts.dart';
import 'package:otraku/widgets/cached_image.dart';
import 'package:otraku/widgets/layouts/top_bar.dart';
import 'package:otraku/widgets/overlays/dialogs.dart';
import 'package:otraku/widgets/overlays/sheets.dart';

class ReviewHeader extends StatelessWidget {
  const ReviewHeader({
    required this.id,
    required this.bannerUrl,
    required this.mediaTitle,
    required this.siteUrl,
  });

  final int id;
  final String? bannerUrl;
  final String? mediaTitle;
  final String? siteUrl;

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _HeaderDelegate(id, bannerUrl, mediaTitle, siteUrl),
    );
  }
}

class _HeaderDelegate extends SliverPersistentHeaderDelegate {
  _HeaderDelegate(this.id, this.bannerUrl, this.title, this.siteUrl);

  final int id;
  final String? bannerUrl;
  final String? title;
  final String? siteUrl;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final extent = maxExtent - shrinkOffset;
    final opacity = shrinkOffset < (maxExtent - minExtent)
        ? shrinkOffset / (maxExtent - minExtent)
        : 1.0;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
      ),
      child: FlexibleSpaceBar.createSettings(
        minExtent: minExtent,
        maxExtent: maxExtent,
        currentExtent: extent > minExtent ? extent : minExtent,
        child: Stack(
          fit: StackFit.expand,
          children: [
            FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              stretchModes: const [StretchMode.zoomBackground],
              background: Column(
                children: [
                  if (bannerUrl != null)
                    Expanded(
                      child: GestureDetector(
                        child: Hero(tag: id, child: CachedImage(bannerUrl!)),
                        onTap: () =>
                            showPopUp(context, ImageDialog(bannerUrl!)),
                      ),
                    ),

                  /// An annoying workaround for a bug in the
                  /// anti-aliasing of the overlaying [DecoratedBox].
                  Container(
                    color: Theme.of(context).colorScheme.background,
                    height: 1,
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: maxExtent * 0.4,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Theme.of(context).colorScheme.background,
                      Theme.of(context).colorScheme.background.withAlpha(0),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: minExtent,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Theme.of(context).colorScheme.background,
                      Theme.of(context).colorScheme.background.withAlpha(0),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: minExtent,
              child: Opacity(
                opacity: opacity,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.background,
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 10,
                        spreadRadius: 10,
                        color: Theme.of(context).colorScheme.background,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: minExtent,
              child: Row(
                children: [
                  TopBarIcon(
                    tooltip: 'Close',
                    icon: Ionicons.chevron_back_outline,
                    onTap: Navigator.of(context).pop,
                  ),
                  if (title != null)
                    Expanded(
                      child: Opacity(
                        opacity: opacity,
                        child: Text(
                          title!,
                          style: Theme.of(context).textTheme.titleMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  if (siteUrl != null)
                    TopBarIcon(
                      tooltip: 'More',
                      icon: Ionicons.ellipsis_horizontal,
                      onTap: () => showSheet(
                        context,
                        FixedGradientDragSheet.link(context, siteUrl!),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  double get maxExtent => 150;

  @override
  double get minExtent => Consts.tapTargetSize;

  @override
  OverScrollHeaderStretchConfiguration? get stretchConfiguration =>
      OverScrollHeaderStretchConfiguration(stretchTriggerOffset: 100);

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      true;

  @override
  PersistentHeaderShowOnScreenConfiguration? get showOnScreenConfiguration =>
      null;

  @override
  FloatingHeaderSnapConfiguration? get snapConfiguration => null;

  @override
  TickerProvider? get vsync => null;
}
