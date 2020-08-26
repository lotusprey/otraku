import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:otraku/providers/theming.dart';
import 'package:provider/provider.dart';

class HeadlineHeader implements SliverPersistentHeaderDelegate {
  final String headline;

  Palette _palette;
  double _height;

  HeadlineHeader({@required this.headline, @required BuildContext context}) {
    _palette = Provider.of<Theming>(context, listen: false).palette;
    _height = 40;
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
          width: double.infinity,
          padding: EdgeInsets.only(left: 15, right: 15, top: 10),
          color: _palette.background.withAlpha(210),
          child: Text(
            headline,
            style: _palette.headline.copyWith(height: 1),
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
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => true;

  @override
  FloatingHeaderSnapConfiguration get snapConfiguration => null;

  @override
  OverScrollHeaderStretchConfiguration get stretchConfiguration => null;
}
