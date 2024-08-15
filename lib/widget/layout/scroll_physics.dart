import 'package:flutter/material.dart';

class FastTabBarViewScrollPhysics extends ScrollPhysics {
  const FastTabBarViewScrollPhysics({super.parent});

  @override
  FastTabBarViewScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return FastTabBarViewScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  SpringDescription get spring => const SpringDescription(
        mass: 50,
        stiffness: 100,
        damping: 0.8,
      );
}
