import 'dart:ui';

import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:otraku/controllers/config.dart';
import 'package:otraku/controllers/notifications.dart';
import 'package:otraku/controllers/viewer.dart';
import 'package:otraku/enums/activity_type.dart';
import 'package:otraku/enums/themes.dart';
import 'package:otraku/pages/pushable/notifications_page.dart';
import 'package:otraku/tools/fields/two_state_field.dart';
import 'package:otraku/tools/navigation/bubble_tabs.dart';

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
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: _height,
          padding: const EdgeInsets.only(left: 10),
          color: Theme.of(context).cardColor,
          child: Row(
            children: [
              GestureDetector(
                onTap: () => viewer.scrollTo(0),
                child: Text(
                  'Feed',
                  style: Theme.of(context).textTheme.headline3.copyWith(
                        color: Theme.of(context).disabledColor,
                      ),
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.filter_alt_outlined),
                onPressed: () => showModalBottomSheet(
                  context: context,
                  builder: (_) => _FilterSheet(viewer),
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                ),
              ),
              IconButton(
                padding: const EdgeInsets.all(0),
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () => Get.to(
                  NotificationsPage(),
                  binding: BindingsBuilder.put(
                    () => Notifications()..fetchData(),
                  ),
                ),
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

class _FilterSheet extends StatelessWidget {
  final Viewer viewer;

  _FilterSheet(this.viewer);

  @override
  Widget build(BuildContext context) {
    bool isFollowing = viewer.isFollowing;
    final typeIn = viewer.typeIn;

    final sideMargin = MediaQuery.of(context).size.width > 420
        ? (MediaQuery.of(context).size.width - 400) / 2
        : 20.0;

    return Container(
      height: 375,
      margin: EdgeInsets.only(
        left: sideMargin,
        right: sideMargin,
        bottom: MediaQuery.of(context).viewPadding.bottom + 10,
      ),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).backgroundColor,
        borderRadius: Config.BORDER_RADIUS,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: Config.PADDING,
            child: Text('People', style: Theme.of(context).textTheme.headline4),
          ),
          BubbleTabs(
            options: ['Following', 'Everyone', 'Not Following'],
            values: [true, null, false],
            initial: isFollowing,
            onNewValue: (val) => isFollowing = val,
            onSameValue: (_) {},
          ),
          Padding(
            padding: Config.PADDING,
            child: Text('Type', style: Theme.of(context).textTheme.headline4),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (_, index) => TwoStateField(
              title: ActivityType.values[index].text,
              initial: typeIn.contains(ActivityType.values[index]),
              onChanged: (val) => val
                  ? typeIn.add(ActivityType.values[index])
                  : typeIn.remove(ActivityType.values[index]),
            ),
            itemCount: ActivityType.values.length,
          ),
          Center(
            child: FlatButton.icon(
              onPressed: () {
                viewer.updateFilters(isFollowing, typeIn);
                Navigator.pop(context);
              },
              icon: Icon(
                FluentSystemIcons.ic_fluent_checkmark_filled,
                color: Theme.of(context).accentColor,
                size: Styles.ICON_SMALLER,
              ),
              label: Text('Done', style: Theme.of(context).textTheme.headline5),
            ),
          ),
        ],
      ),
    );
  }
}
