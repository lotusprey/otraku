import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:otraku/pages/tab_manager.dart';
import 'package:otraku/providers/theming.dart';
import 'package:otraku/providers/view_config.dart';
import 'package:provider/provider.dart';

class CustomTabBar extends StatefulWidget {
  @override
  _CustomTabBarState createState() => _CustomTabBarState();
}

class _CustomTabBarState extends State<CustomTabBar> {
  bool _didChangeDependencies = false;

  Palette _palette;
  int _pageIndex;

  //Create a button fro the tab bar
  Widget _tabButton(Icon icon, int index) {
    return IconButton(
      icon: icon,
      iconSize: Palette.ICON_BIG,
      color: _pageIndex == index ? _palette.primary : _palette.faded,
      onPressed: () {
        if (_pageIndex != index) {
          Provider.of<ViewConfig>(context, listen: false).switchPage(index);
          setState(() => _pageIndex = index);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(7);

    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: 255,
          height: 51,
          decoration: BoxDecoration(
            color: _palette.primary.withAlpha(210),
            borderRadius: radius,
          ),
          child: Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 400),
                left: _pageIndex * 51.0,
                curve: Curves.decelerate,
                child: Container(
                  height: 51,
                  width: 51,
                  decoration: BoxDecoration(
                    borderRadius: radius,
                    color: _palette.accent,
                  ),
                ),
              ),
              Row(
                children: <Widget>[
                  _tabButton(const Icon(Icons.inbox), TabManager.INBOX),
                  _tabButton(
                      const Icon(Icons.play_arrow), TabManager.ANIME_LIST),
                  _tabButton(const Icon(Icons.bookmark), TabManager.MANGA_LIST),
                  _tabButton(const Icon(Icons.explore), TabManager.EXPLORE),
                  _tabButton(const Icon(Icons.person), TabManager.PROFILE),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _palette = Provider.of<Theming>(context).palette;
    if (!_didChangeDependencies) {
      _pageIndex = Provider.of<ViewConfig>(context, listen: false).pageIndex;
      _didChangeDependencies = true;
    }
  }
}
