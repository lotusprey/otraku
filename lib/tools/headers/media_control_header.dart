import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:otraku/providers/theming.dart';
import 'package:otraku/tools/navigation/title_segmented_control.dart';
import 'package:provider/provider.dart';

class MediaControlHeader implements SliverPersistentHeaderDelegate {
  static const double _height = 100;

  final Function(Object value) updateSegmentedControl;
  final Map<String, Object> segmentedControlPairs;
  final Function searchActivate;
  final Function searchDeactivate;
  final bool isSearchActive;
  final Function filterActivate;
  final Function filterDeactivate;
  final bool isFilterActive;
  final Function refresh;
  final Function sort;
  Palette _palette;

  MediaControlHeader({
    @required this.updateSegmentedControl,
    @required this.segmentedControlPairs,
    @required this.searchActivate,
    @required this.searchDeactivate,
    @required this.isSearchActive,
    @required this.filterActivate,
    @required this.filterDeactivate,
    @required this.isFilterActive,
    @required this.refresh,
    @required this.sort,
    @required BuildContext context,
  }) {
    _palette = Provider.of<Theming>(context, listen: false).palette;
  }

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
          padding: const EdgeInsets.only(top: 15, left: 15, right: 15),
          color: _palette.background.withAlpha(210),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TitleSegmentedControl(
                function: updateSegmentedControl,
                pairs: segmentedControlPairs,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      _HeaderButton(
                        icon: LineAwesomeIcons.search,
                        turnOn: () => searchActivate(),
                        turnOff: () => searchDeactivate(),
                        active: isSearchActive,
                      ),
                      _HeaderButton(
                        icon: LineAwesomeIcons.filter,
                        turnOn: () => filterActivate(),
                        turnOff: () => filterDeactivate(),
                        active: isFilterActive,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(LineAwesomeIcons.retweet),
                        color: _palette.faded,
                        iconSize: Palette.ICON_MEDIUM,
                        onPressed: () => refresh(),
                      ),
                      IconButton(
                        icon: const Icon(LineAwesomeIcons.sort),
                        color: _palette.faded,
                        iconSize: Palette.ICON_MEDIUM,
                        onPressed: () => sort(),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  double get minExtent => _height;

  @override
  double get maxExtent => _height;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => true;

  @override
  FloatingHeaderSnapConfiguration get snapConfiguration => null;

  @override
  OverScrollHeaderStretchConfiguration get stretchConfiguration => null;
}

class _HeaderButton extends StatelessWidget {
  final IconData icon;
  final Function turnOn;
  final Function turnOff;
  final bool active;

  _HeaderButton({
    @required this.icon,
    @required this.turnOn,
    @required this.turnOff,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    final palette = Provider.of<Theming>(context, listen: false).palette;

    return active
        ? Container(
            margin: const EdgeInsets.only(right: 10),
            padding: const EdgeInsets.symmetric(vertical: 3),
            decoration: BoxDecoration(
              color: palette.accent,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: const BoxDecoration(
                    border: Border(
                      right: BorderSide(
                        width: 1,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  child: GestureDetector(
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: Palette.ICON_MEDIUM,
                    ),
                    onTap: () => turnOn(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: GestureDetector(
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: Palette.ICON_SMALL,
                    ),
                    onTap: () => turnOff(),
                  ),
                ),
              ],
            ),
          )
        : IconButton(
            icon: Icon(icon),
            color: palette.faded,
            iconSize: Palette.ICON_MEDIUM,
            onPressed: () => turnOn(),
          );
  }
}
