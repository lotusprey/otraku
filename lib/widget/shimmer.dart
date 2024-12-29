import 'package:flutter/material.dart';

class Shimmer extends StatefulWidget {
  static ShimmerState? of(BuildContext context) =>
      context.findAncestorStateOfType<ShimmerState>();

  const Shimmer(this.child);

  final Widget child;

  @override
  ShimmerState createState() => ShimmerState();
}

class ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late LinearGradient _gradient;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController.unbounded(vsync: this, value: 0.5)
      ..repeat(min: -0.5, max: 1.5, period: const Duration(milliseconds: 1000));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final back = ColorScheme.of(context).surfaceContainerHighest;
    final hsl = HSLColor.fromColor(back);
    final l = hsl.lightness;
    final front = hsl.withLightness(l < 0.5 ? l + 0.1 : l - 0.1).toColor();

    _gradient = LinearGradient(
      begin: const Alignment(-1.0, -0.3),
      end: const Alignment(1.0, 0.3),
      stops: const [0.1, 0.3, 0.4],
      colors: [back, front, back],
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Listenable get animation => _ctrl;

  LinearGradient get gradient => LinearGradient(
        transform: _SlidingGradientTransform(_ctrl.value),
        colors: _gradient.colors,
        stops: _gradient.stops,
        begin: _gradient.begin,
        end: _gradient.end,
      );

  Size? get size {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return null;
    return box.size;
  }

  Offset getOffset(RenderBox descendant) => descendant.localToGlobal(
        Offset.zero,
        ancestor: context.findRenderObject() as RenderBox,
      );

  @override
  Widget build(BuildContext context) => widget.child;
}

class ShimmerItem extends StatefulWidget {
  const ShimmerItem(this.child);

  final Widget child;

  @override
  ShimmerItemState createState() => ShimmerItemState();
}

class ShimmerItemState extends State<ShimmerItem> {
  Listenable? _anim;

  void _update() => setState(() {});

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _anim?.removeListener(_update);
    _anim = Shimmer.of(context)?.animation?..addListener(_update);
  }

  @override
  void dispose() {
    _anim?.removeListener(_update);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shimmer = Shimmer.of(context);
    if (shimmer == null) return const SizedBox();

    final size = shimmer.size;
    if (size == null) return const SizedBox();

    final offset = shimmer.getOffset(context.findRenderObject() as RenderBox);

    return ShaderMask(
      blendMode: BlendMode.srcATop,
      shaderCallback: (bounds) => shimmer.gradient.createShader(
        Rect.fromLTWH(-offset.dx, -offset.dy, size.width, size.height),
      ),
      child: widget.child,
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  const _SlidingGradientTransform(this.percent);

  final double percent;

  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) =>
      Matrix4.translationValues(bounds.width * percent, 0.0, 0.0);
}
