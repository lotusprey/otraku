import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class Shimmer extends StatefulWidget {
  final Widget child;
  Shimmer(this.child, {Key? key}) : super(key: key);

  @override
  _ShimmerState createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Gradient _gradient;
  bool _initDone = false;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _ctrl,
        child: widget.child,
        builder: (_, child) => _Shimmer(
          child: child!,
          gradient: _gradient,
          percent: _ctrl.value,
        ),
      );

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController.unbounded(
      vsync: this,
      duration: const Duration(seconds: 1),
      value: 1,
    )..repeat(min: -0.5, max: 1.5);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initDone) {
      final back = Theme.of(context).primaryColor;
      final hsl = HSLColor.fromColor(back);
      final lightness = hsl.lightness;
      final front = hsl
          .withLightness(lightness < 0.5 ? lightness + 0.1 : lightness - 0.1)
          .toColor();

      _gradient = LinearGradient(
        begin: const Alignment(-1.0, -0.3),
        end: const Alignment(1.0, 0.3),
        colors: [back, front, back],
        stops: const [0.1, 0.3, 0.4],
      );

      _initDone = true;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }
}

@immutable
class _Shimmer extends SingleChildRenderObjectWidget {
  final double percent;
  final Gradient gradient;

  const _Shimmer({
    required Widget child,
    required this.percent,
    required this.gradient,
  }) : super(child: child);

  @override
  _ShimmerFilter createRenderObject(BuildContext context) =>
      _ShimmerFilter(percent, gradient);

  @override
  void updateRenderObject(BuildContext context, _ShimmerFilter shimmer) {
    shimmer.percent = percent;
    shimmer.gradient = gradient;
  }
}

class _ShimmerFilter extends RenderProxyBox {
  Gradient _gradient;
  double _percent;

  _ShimmerFilter(this._percent, this._gradient);

  @override
  ShaderMaskLayer? get layer => super.layer as ShaderMaskLayer?;

  @override
  bool get alwaysNeedsCompositing => child != null;

  set percent(double val) {
    if (_percent == val) return;
    _percent = val;
    markNeedsPaint();
  }

  set gradient(Gradient val) {
    if (_gradient == val) return;
    _gradient = val;
    markNeedsPaint();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child == null) {
      layer = null;
      return;
    }

    assert(needsCompositing);

    final width = child!.size.width;
    final height = child!.size.height;

    final dx = 2 * width * (_percent - 1);
    final rect = Rect.fromLTWH(dx, 0, 3 * width, height);

    layer ??= ShaderMaskLayer();
    layer!
      ..shader = _gradient.createShader(rect)
      ..maskRect = offset & size
      ..blendMode = BlendMode.srcIn;
    context.pushLayer(layer!, super.paint, offset);
  }
}
