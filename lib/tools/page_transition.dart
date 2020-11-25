import 'dart:io';

import 'package:flutter/cupertino.dart';

class PageTransition extends PageRouteBuilder {
  static Route route({
    @required Widget builder,
    RouteSettings settings,
  }) {
    if (Platform.isAndroid || Platform.isFuchsia)
      return PageTransition(
        pageBuilder: (_, __, ___) => builder,
        settings: settings,
      );

    return CupertinoPageRoute(
      builder: (_) => builder,
      settings: settings,
    );
  }

  PageTransition({
    @required RoutePageBuilder pageBuilder,
    RouteSettings settings,
  }) : super(
          pageBuilder: pageBuilder,
          settings: settings,
          transitionDuration: const Duration(milliseconds: 400),
          reverseTransitionDuration: const Duration(milliseconds: 400),
        );

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curve = animation.status == AnimationStatus.reverse
        ? Curves.easeInToLinear
        : Curves.linearToEaseOut;

    return SlideTransition(
      position: animation.drive(
        Tween(begin: const Offset(0, 1), end: Offset.zero)
            .chain(CurveTween(curve: curve)),
      ),
      child: child,
    );
  }
}
