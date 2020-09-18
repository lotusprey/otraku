import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:otraku/pages/tab_manager.dart';
import 'package:otraku/providers/theming.dart';
import 'package:otraku/providers/view_config.dart';
import 'package:provider/provider.dart';

class CustomTabBar extends StatefulWidget {
  final ScrollController scrollCtrl;

  CustomTabBar(this.scrollCtrl);

  @override
  _CustomTabBarState createState() => _CustomTabBarState();
}

class _CustomTabBarState extends State<CustomTabBar>
    with SingleTickerProviderStateMixin {
  bool _didChangeDependencies = false;

  Palette _palette;
  int _pageIndex;

  bool _didScrollDown = false;
  bool _hide = false;
  AnimationController _animationController;
  Animation<double> _fadeAnimation;

  void _scrollListener() {
    if (widget.scrollCtrl.position.userScrollDirection ==
        ScrollDirection.idle) {
      return;
    }

    bool newScrollisDown = widget.scrollCtrl.position.userScrollDirection ==
        ScrollDirection.reverse;

    if (newScrollisDown != _didScrollDown) {
      _didScrollDown = newScrollisDown;
      if (_didScrollDown) {
        _animationController
            .forward()
            .then((_) => setState(() => _hide = true));
      } else {
        setState(() => _hide = false);
        _animationController.reverse();
      }
    }
  }

  Widget _tabButton(Icon icon, int index) {
    return IconButton(
      icon: icon,
      iconSize: Palette.ICON_BIG,
      color: _pageIndex == index ? _palette.background : _palette.faded,
      onPressed: () {
        if (_pageIndex != index) {
          Provider.of<ViewConfig>(context, listen: false).pageIndex = index;
          setState(() => _pageIndex = index);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(7);

    return Visibility(
      visible: MediaQuery.of(context).viewInsets.bottom == 0,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: !_hide
            ? DecoratedBox(
                decoration: const BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: radius,
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      width: 255,
                      height: 51,
                      decoration: BoxDecoration(
                        color: _palette.background.withAlpha(200),
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
                              _tabButton(
                                  const Icon(Icons.inbox), TabManager.INBOX),
                              _tabButton(const Icon(Icons.play_arrow),
                                  TabManager.ANIME_LIST),
                              _tabButton(const Icon(Icons.bookmark),
                                  TabManager.MANGA_LIST),
                              _tabButton(const Icon(Icons.explore),
                                  TabManager.EXPLORE),
                              _tabButton(
                                  const Icon(Icons.person), TabManager.PROFILE),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            : const SizedBox(),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    widget.scrollCtrl.addListener(_scrollListener);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 1,
      end: 0,
    ).animate(_animationController);
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

  @override
  void dispose() {
    widget.scrollCtrl.removeListener(_scrollListener);
    _animationController.dispose();
    super.dispose();
  }
}

class DisableAnimationAnimator extends FloatingActionButtonAnimator {
  const DisableAnimationAnimator();

  @override
  Offset getOffset({Offset begin, Offset end, double progress}) {
    return end;
  }

  @override
  Animation<double> getRotationAnimation({Animation<double> parent}) {
    return Tween<double>(begin: 1.0, end: 1.0).animate(parent);
  }

  @override
  Animation<double> getScaleAnimation({Animation<double> parent}) {
    return Tween<double>(begin: 1.0, end: 1.0).animate(parent);
  }
}
