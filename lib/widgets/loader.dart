import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Loader extends StatefulWidget {
  const Loader();
  @override
  _LoaderState createState() => _LoaderState();
}

class _LoaderState extends State<Loader> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<Color?> _animation1;
  late Animation<Color?> _animation2;
  late Animation<Color?> _animation3;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    final color = Get.theme!.accentColor;
    final red = color.red;
    final green = color.green;
    final blue = color.blue;

    final red2 = 255 - red;
    final green2 = 255 - green;
    final blue2 = 255 - blue;

    final dark = Color.fromARGB(
      255,
      (red * 0.80).floor(),
      (green * 0.80).floor(),
      (blue * 0.80).floor(),
    );

    final light = Color.fromARGB(
      255,
      red + (red2 * 0.20).floor(),
      green + (green2 * 0.20).floor(),
      blue + (blue2 * 0.20).floor(),
    );

    final darkToMiddle = TweenSequenceItem(
      tween: ColorTween(begin: dark, end: color),
      weight: 25,
    );
    final middleToLight = TweenSequenceItem(
      tween: ColorTween(begin: color, end: light),
      weight: 25,
    );
    final lightToMiddle = TweenSequenceItem(
      tween: ColorTween(begin: light, end: color),
      weight: 25,
    );
    final middleToDark = TweenSequenceItem(
      tween: ColorTween(begin: color, end: dark),
      weight: 25,
    );

    _animation1 = TweenSequence([
      darkToMiddle,
      middleToLight,
      lightToMiddle,
      middleToDark,
    ]).animate(_ctrl);

    _animation2 = TweenSequence([
      middleToDark,
      darkToMiddle,
      middleToLight,
      lightToMiddle,
    ]).animate(_ctrl);

    _animation3 = TweenSequence([
      lightToMiddle,
      middleToDark,
      darkToMiddle,
      middleToLight,
    ]).animate(_ctrl);

    _ctrl.repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 55,
      height: 15,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _LoadingCircle(_animation1),
          _LoadingCircle(_animation2),
          _LoadingCircle(_animation3),
        ],
      ),
    );
  }
}

class _LoadingCircle extends AnimatedWidget {
  _LoadingCircle(Animation<Color?> animation) : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 15,
      height: 15,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: (listenable as Animation<Color?>).value,
      ),
    );
  }
}
