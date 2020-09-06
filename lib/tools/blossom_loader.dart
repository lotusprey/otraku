import 'package:flutter/material.dart';
import 'package:otraku/providers/theming.dart';
import 'package:provider/provider.dart';

class BlossomLoader extends StatefulWidget {
  final double size;

  const BlossomLoader({this.size = 50});

  @override
  _BlossomLoaderState createState() => _BlossomLoaderState();
}

class _BlossomLoaderState extends State<BlossomLoader>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<Color> _animation1;
  Animation<Color> _animation2;
  Animation<Color> _animation3;
  Animation<Color> _animation4;
  double _diameter;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.size,
      height: widget.size,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _AnimatedCircle(diameter: _diameter, animation: _animation1),
              _AnimatedCircle(diameter: _diameter, animation: _animation2),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _AnimatedCircle(diameter: _diameter, animation: _animation4),
              _AnimatedCircle(diameter: _diameter, animation: _animation3),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _diameter = (widget.size - 3) / 2;

    final color = Provider.of<Theming>(context, listen: false).palette.accent;

    final red = color.red;
    final green = color.green;
    final blue = color.blue;

    final red2 = 255 - red;
    final green2 = 255 - green;
    final blue2 = 255 - blue;

    final dark = Color.fromARGB(
      255,
      (red * 0.85).floor(),
      (green * 0.85).floor(),
      (blue * 0.85).floor(),
    );

    final darker = Color.fromARGB(
      255,
      (red * 0.70).floor(),
      (green * 0.70).floor(),
      (blue * 0.70).floor(),
    );

    final light = Color.fromARGB(
      255,
      red + (red2 * 0.15).floor(),
      green + (green2 * 0.15).floor(),
      blue + (blue2 * 0.15).floor(),
    );

    final lighter = Color.fromARGB(
      255,
      red + (red2 * 0.30).floor(),
      green + (green2 * 0.30).floor(),
      blue + (blue2 * 0.30).floor(),
    );

    final darkerDark = TweenSequenceItem<Color>(
      tween: ColorTween(begin: darker, end: dark),
      weight: 16.6,
    );
    final darkLight = TweenSequenceItem<Color>(
      tween: ColorTween(begin: dark, end: light),
      weight: 16.6,
    );
    final lightLighter = TweenSequenceItem<Color>(
      tween: ColorTween(begin: light, end: lighter),
      weight: 16.6,
    );
    final lighterLight = TweenSequenceItem<Color>(
      tween: ColorTween(begin: lighter, end: light),
      weight: 16.6,
    );
    final lightDark = TweenSequenceItem<Color>(
      tween: ColorTween(begin: light, end: dark),
      weight: 16.6,
    );
    final darkDarker = TweenSequenceItem<Color>(
      tween: ColorTween(begin: dark, end: darker),
      weight: 16.6,
    );

    _animation1 = TweenSequence([
      lightDark,
      darkDarker,
      darkerDark,
      darkLight,
      lightLighter,
      lighterLight,
    ]).animate(_controller);

    _animation2 = TweenSequence([
      lighterLight,
      lightDark,
      darkDarker,
      darkerDark,
      darkLight,
      lightLighter,
    ]).animate(_controller);

    _animation3 = TweenSequence([
      darkerDark,
      darkLight,
      lightLighter,
      lighterLight,
      lightDark,
      darkDarker,
    ]).animate(_controller);

    _animation4 = TweenSequence([
      darkDarker,
      darkerDark,
      darkLight,
      lightLighter,
      lighterLight,
      lightDark,
    ]).animate(_controller);

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _AnimatedCircle extends AnimatedWidget {
  final double diameter;

  _AnimatedCircle({
    @required this.diameter,
    Key key,
    Animation<Color> animation,
  }) : super(key: key, listenable: animation);

  @override
  Widget build(BuildContext context) {
    final animation = listenable as Animation<Color>;
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: animation.value,
      ),
    );
  }
}
