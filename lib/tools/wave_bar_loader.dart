import 'package:flutter/material.dart';
import 'package:otraku/providers/theming.dart';
import 'package:provider/provider.dart';

class WaveBarLoader extends StatefulWidget {
  final double sizeVariable;

  const WaveBarLoader({this.sizeVariable = 1});

  @override
  _WaveBarLoaderState createState() => _WaveBarLoaderState();
}

class _WaveBarLoaderState extends State<WaveBarLoader>
    with SingleTickerProviderStateMixin {
  Palette _palette;
  AnimationController _controller;
  List<_Bar> _bars;

  _initBar(double begin, double end) {
    return _Bar(
      color: _palette.accent,
      animation: TweenSequence(
        [
          TweenSequenceItem<double>(
            tween: Tween(begin: 40.0, end: 60.0),
            weight: 50.0,
          ),
          TweenSequenceItem<double>(
            tween: Tween(begin: 60.0, end: 40.0),
            weight: 50.0,
          ),
        ],
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Interval(begin, end),
      )),
    );
  }

  @override
  void initState() {
    super.initState();
    _palette = Provider.of<Theming>(context, listen: false).palette;

    _controller = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );

    _bars = [_initBar(0.1, 0.5), _initBar(0.3, 0.7), _initBar(0.5, 0.9)];

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: 60,
        width: 55,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: _bars,
        ),
      ),
    );
  }
}

class _Bar extends AnimatedWidget {
  final Color color;

  _Bar({
    @required Animation<double> animation,
    @required this.color,
    Key key,
  }) : super(key: key, listenable: animation);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 15,
      height: (listenable as Animation<double>).value,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }
}
