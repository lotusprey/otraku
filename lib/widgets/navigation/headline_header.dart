import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/utils/config.dart';
import 'package:otraku/widgets/navigation/app_bars.dart';

class HeadlineHeader extends StatelessWidget {
  final String headline;
  final bool canPop;

  const HeadlineHeader(this.headline, this.canPop);

  @override
  Widget build(BuildContext context) => SliverPersistentHeader(
        pinned: false,
        floating: false,
        delegate: _Delegate(
          context: context,
          headline: headline,
          canPop: canPop,
        ),
      );
}

class _Delegate implements SliverPersistentHeaderDelegate {
  final String headline;
  final bool canPop;

  _Delegate({
    required this.headline,
    required this.canPop,
    required BuildContext context,
  });

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) =>
      Container(
        height: Config.MATERIAL_TAP_TARGET_SIZE,
        child: Row(
          children: [
            if (canPop) ...[
              AppBarIcon(
                tooltip: 'Close',
                icon: Ionicons.chevron_back_outline,
                onTap: () => Navigator.pop(context),
              ),
              Text(
                headline,
                style: Theme.of(context).textTheme.headline3,
                textAlign: TextAlign.center,
              ),
            ] else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  headline,
                  style: Theme.of(context).textTheme.headline3,
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      );

  @override
  double get maxExtent => Config.MATERIAL_TAP_TARGET_SIZE;

  @override
  double get minExtent => Config.MATERIAL_TAP_TARGET_SIZE;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => true;

  @override
  FloatingHeaderSnapConfiguration? get snapConfiguration => null;

  @override
  OverScrollHeaderStretchConfiguration? get stretchConfiguration => null;

  @override
  PersistentHeaderShowOnScreenConfiguration? get showOnScreenConfiguration =>
      null;

  @override
  TickerProvider? get vsync => null;
}
