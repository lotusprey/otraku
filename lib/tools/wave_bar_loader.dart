import 'package:flutter/material.dart';
import 'package:otraku/providers/theming.dart';
import 'package:provider/provider.dart';

class WaveBarLoader extends StatefulWidget {
  final double barWidth;

  const WaveBarLoader({this.barWidth = 15});

  @override
  _WaveBarLoaderState createState() => _WaveBarLoaderState();
}

class _WaveBarLoaderState extends State<WaveBarLoader>
    with SingleTickerProviderStateMixin {
  Palette _palette;
  AnimationController _controller;
  List<_Bar> _bars;
  double _barSpacing;
  double _barHeightMax;
  double _barHeightMin;

  _initBar(double begin, double end) {
    return _Bar(
      width: widget.barWidth,
      color: _palette.accent,
      animation: TweenSequence(
        [
          TweenSequenceItem<double>(
            tween: Tween(begin: _barHeightMin, end: _barHeightMax),
            weight: 50.0,
          ),
          TweenSequenceItem<double>(
            tween: Tween(begin: _barHeightMax, end: _barHeightMin),
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

    _barSpacing = widget.barWidth / 4;
    _barHeightMax = widget.barWidth * 4;
    _barHeightMin = _barHeightMax * 2 / 3;

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
    return SizedBox(
      height: _barHeightMax,
      width: widget.barWidth * 3 + _barSpacing * 2,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: _bars,
      ),
    );
  }
}

class _Bar extends AnimatedWidget {
  final double width;
  final Color color;

  _Bar({
    @required Animation<double> animation,
    @required this.width,
    @required this.color,
    Key key,
  }) : super(key: key, listenable: animation);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: (listenable as Animation<double>).value,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }
}
