import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:otraku/controllers/config.dart';
import 'package:otraku/controllers/viewer.dart';
import 'package:otraku/enums/activity_type.dart';
import 'package:otraku/helpers/fn_helper.dart';
import 'package:otraku/pages/pushable/notifications_page.dart';
import 'package:otraku/tools/navigation/bubble_tabs.dart';
import 'package:otraku/tools/overlays/option_sheet.dart';

class FeedControls extends StatelessWidget {
  final Viewer viewer;

  FeedControls(this.viewer);

  @override
  Widget build(BuildContext context) => SliverPersistentHeader(
        delegate: _FeedControls(viewer),
        pinned: true,
      );
}

class _FeedControls implements SliverPersistentHeaderDelegate {
  static const _height = Config.MATERIAL_TAP_TARGET_SIZE + 5;

  final Viewer viewer;

  _FeedControls(this.viewer);

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return ClipRect(
      child: BackdropFilter(
        filter: FnHelper.filter,
        child: Container(
          height: _height,
          color: Theme.of(context).cardColor,
          child: Row(
            children: [
              BubbleTabs(
                options: ['Following', 'Global'],
                values: [true, false],
                initial: viewer.isFollowing,
                onNewValue: (val) => viewer.updateFilters(following: val),
                onSameValue: (_) => viewer.scrollTo(0),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.filter_alt_outlined),
                onPressed: () => showModalBottomSheet(
                  context: context,
                  builder: (_) => SelectionSheet(
                    options: ActivityType.values.map((v) => v.text).toList(),
                    values: ActivityType.values,
                    inclusive: viewer.typeIn,
                    onDone: (typeIn, _) => viewer.updateFilters(types: typeIn),
                  ),
                  backgroundColor: Colors.transparent,
                ),
              ),
              IconButton(
                padding: const EdgeInsets.all(0),
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () => Get.toNamed(NotificationsPage.ROUTE),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  double get maxExtent => _height;

  @override
  double get minExtent => _height;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      true;

  @override
  PersistentHeaderShowOnScreenConfiguration get showOnScreenConfiguration =>
      null;

  @override
  FloatingHeaderSnapConfiguration get snapConfiguration => null;

  @override
  OverScrollHeaderStretchConfiguration get stretchConfiguration => null;

  @override
  TickerProvider get vsync => null;
}
