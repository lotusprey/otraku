import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class FadeImage extends StatelessWidget {
  const FadeImage(
    this.imageUrl, {
    this.fit = BoxFit.cover,
    this.width = double.infinity,
    this.height = double.infinity,
    this.alignment = Alignment.center,
  });

  final String imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) => _FadeInImage.memoryNetwork(
        fit: fit,
        image: imageUrl,
        width: width,
        height: height,
        alignment: alignment,
        fadeInDuration: const Duration(milliseconds: 300),
        fadeOutDuration: const Duration(milliseconds: 300),
        placeholder: _transparentImage,
        imageErrorBuilder: (_, err, stackTrace) =>
            const Center(child: Icon(Icons.close_outlined)),
      );

  static final Uint8List _transparentImage = Uint8List.fromList(<int>[
    0x89,
    0x50,
    0x4E,
    0x47,
    0x0D,
    0x0A,
    0x1A,
    0x0A,
    0x00,
    0x00,
    0x00,
    0x0D,
    0x49,
    0x48,
    0x44,
    0x52,
    0x00,
    0x00,
    0x00,
    0x01,
    0x00,
    0x00,
    0x00,
    0x01,
    0x08,
    0x06,
    0x00,
    0x00,
    0x00,
    0x1F,
    0x15,
    0xC4,
    0x89,
    0x00,
    0x00,
    0x00,
    0x0A,
    0x49,
    0x44,
    0x41,
    0x54,
    0x78,
    0x9C,
    0x63,
    0x00,
    0x01,
    0x00,
    0x00,
    0x05,
    0x00,
    0x01,
    0x0D,
    0x0A,
    0x2D,
    0xB4,
    0x00,
    0x00,
    0x00,
    0x00,
    0x49,
    0x45,
    0x4E,
    0x44,
    0xAE,
  ]);
}

// ignore_for_file: unused_element

/// To be removed.
/// There's a bad bug with Flutter [FadeInImage] currently.
/// A fix is pushed, but not merged into stable yet.
/// Until that happens, this replacement is to be used.
/// For more info: https://github.com/flutter/flutter/pull/111035#issuecomment-1270273169
class _FadeInImage extends StatefulWidget {
  _FadeInImage.memoryNetwork({
    super.key,
    required Uint8List placeholder,
    this.placeholderErrorBuilder,
    required String image,
    this.imageErrorBuilder,
    double placeholderScale = 1.0,
    double imageScale = 1.0,
    this.excludeFromSemantics = false,
    this.imageSemanticLabel,
    this.fadeOutDuration = const Duration(milliseconds: 300),
    this.fadeOutCurve = Curves.easeOut,
    this.fadeInDuration = const Duration(milliseconds: 700),
    this.fadeInCurve = Curves.easeIn,
    this.width,
    this.height,
    this.fit,
    this.placeholderFit,
    this.alignment = Alignment.center,
    this.repeat = ImageRepeat.noRepeat,
    this.matchTextDirection = false,
    int? placeholderCacheWidth,
    int? placeholderCacheHeight,
    int? imageCacheWidth,
    int? imageCacheHeight,
  })  : placeholder = ResizeImage.resizeIfNeeded(
          placeholderCacheWidth,
          placeholderCacheHeight,
          MemoryImage(placeholder, scale: placeholderScale),
        ),
        image = ResizeImage.resizeIfNeeded(
          imageCacheWidth,
          imageCacheHeight,
          NetworkImage(image, scale: imageScale),
        );

  final ImageProvider placeholder;
  final ImageErrorWidgetBuilder? placeholderErrorBuilder;
  final ImageProvider image;
  final ImageErrorWidgetBuilder? imageErrorBuilder;
  final Duration fadeOutDuration;
  final Curve fadeOutCurve;
  final Duration fadeInDuration;
  final Curve fadeInCurve;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final BoxFit? placeholderFit;
  final AlignmentGeometry alignment;
  final ImageRepeat repeat;
  final bool matchTextDirection;
  final bool excludeFromSemantics;
  final String? imageSemanticLabel;

  @override
  State<_FadeInImage> createState() => _FadeInImageState();
}

class _FadeInImageState extends State<_FadeInImage> {
  static const Animation<double> _kOpaqueAnimation =
      AlwaysStoppedAnimation<double>(1.0);
  bool targetLoaded = false;

  final ProxyAnimation _imageAnimation = ProxyAnimation(_kOpaqueAnimation);
  final ProxyAnimation _placeholderAnimation =
      ProxyAnimation(_kOpaqueAnimation);

  Image _image({
    required ImageProvider image,
    ImageErrorWidgetBuilder? errorBuilder,
    ImageFrameBuilder? frameBuilder,
    BoxFit? fit,
    required Animation<double> opacity,
  }) {
    return Image(
      image: image,
      errorBuilder: errorBuilder,
      frameBuilder: frameBuilder,
      opacity: opacity,
      width: widget.width,
      height: widget.height,
      fit: fit,
      alignment: widget.alignment,
      repeat: widget.repeat,
      matchTextDirection: widget.matchTextDirection,
      gaplessPlayback: true,
      excludeFromSemantics: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget result = _image(
      image: widget.image,
      errorBuilder: widget.imageErrorBuilder,
      opacity: _imageAnimation,
      fit: widget.fit,
      frameBuilder: (BuildContext context, Widget child, int? frame,
          bool wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded || frame != null) {
          targetLoaded = true;
        }
        return _AnimatedFadeOutFadeIn(
          target: child,
          targetProxyAnimation: _imageAnimation,
          placeholder: _image(
            image: widget.placeholder,
            errorBuilder: widget.placeholderErrorBuilder,
            opacity: _placeholderAnimation,
            fit: widget.placeholderFit ?? widget.fit,
          ),
          placeholderProxyAnimation: _placeholderAnimation,
          isTargetLoaded: targetLoaded,
          wasSynchronouslyLoaded: wasSynchronouslyLoaded,
          fadeInDuration: widget.fadeInDuration,
          fadeOutDuration: widget.fadeOutDuration,
          fadeInCurve: widget.fadeInCurve,
          fadeOutCurve: widget.fadeOutCurve,
        );
      },
    );

    if (!widget.excludeFromSemantics) {
      result = Semantics(
        container: widget.imageSemanticLabel != null,
        image: true,
        label: widget.imageSemanticLabel ?? '',
        child: result,
      );
    }

    return result;
  }
}

class _AnimatedFadeOutFadeIn extends ImplicitlyAnimatedWidget {
  const _AnimatedFadeOutFadeIn({
    required this.target,
    required this.targetProxyAnimation,
    required this.placeholder,
    required this.placeholderProxyAnimation,
    required this.isTargetLoaded,
    required this.fadeOutDuration,
    required this.fadeOutCurve,
    required this.fadeInDuration,
    required this.fadeInCurve,
    required this.wasSynchronouslyLoaded,
  })  : assert(!wasSynchronouslyLoaded || isTargetLoaded),
        super(duration: fadeInDuration + fadeOutDuration);

  final Widget target;
  final ProxyAnimation targetProxyAnimation;
  final Widget placeholder;
  final ProxyAnimation placeholderProxyAnimation;
  final bool isTargetLoaded;
  final Duration fadeInDuration;
  final Duration fadeOutDuration;
  final Curve fadeInCurve;
  final Curve fadeOutCurve;
  final bool wasSynchronouslyLoaded;

  @override
  _AnimatedFadeOutFadeInState createState() => _AnimatedFadeOutFadeInState();
}

class _AnimatedFadeOutFadeInState
    extends ImplicitlyAnimatedWidgetState<_AnimatedFadeOutFadeIn> {
  Tween<double>? _targetOpacity;
  Tween<double>? _placeholderOpacity;
  Animation<double>? _targetOpacityAnimation;
  Animation<double>? _placeholderOpacityAnimation;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _targetOpacity = visitor(
      _targetOpacity,
      widget.isTargetLoaded ? 1.0 : 0.0,
      (dynamic value) => Tween<double>(begin: value as double),
    ) as Tween<double>?;
    _placeholderOpacity = visitor(
      _placeholderOpacity,
      widget.isTargetLoaded ? 0.0 : 1.0,
      (dynamic value) => Tween<double>(begin: value as double),
    ) as Tween<double>?;
  }

  @override
  void didUpdateTweens() {
    if (widget.wasSynchronouslyLoaded) {
      return;
    }

    _placeholderOpacityAnimation =
        animation.drive(TweenSequence<double>(<TweenSequenceItem<double>>[
      TweenSequenceItem<double>(
        tween:
            _placeholderOpacity!.chain(CurveTween(curve: widget.fadeOutCurve)),
        weight: widget.fadeOutDuration.inMilliseconds.toDouble(),
      ),
      TweenSequenceItem<double>(
        tween: ConstantTween<double>(0),
        weight: widget.fadeInDuration.inMilliseconds.toDouble(),
      ),
    ]))
          ..addStatusListener((AnimationStatus status) {
            if (_placeholderOpacityAnimation!.isCompleted) {
              setState(() {});
            }
          });

    _targetOpacityAnimation =
        animation.drive(TweenSequence<double>(<TweenSequenceItem<double>>[
      TweenSequenceItem<double>(
        tween: ConstantTween<double>(0),
        weight: widget.fadeOutDuration.inMilliseconds.toDouble(),
      ),
      TweenSequenceItem<double>(
        tween: _targetOpacity!.chain(CurveTween(curve: widget.fadeInCurve)),
        weight: widget.fadeInDuration.inMilliseconds.toDouble(),
      ),
    ]));

    widget.targetProxyAnimation.parent = _targetOpacityAnimation;
    widget.placeholderProxyAnimation.parent = _placeholderOpacityAnimation;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.wasSynchronouslyLoaded ||
        (_placeholderOpacityAnimation?.isCompleted ?? true)) {
      return widget.target;
    }

    return Stack(
      fit: StackFit.passthrough,
      alignment: AlignmentDirectional.center,
      textDirection: TextDirection.ltr,
      children: <Widget>[
        widget.target,
        widget.placeholder,
      ],
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Animation<double>>(
        'targetOpacity', _targetOpacityAnimation));
    properties.add(DiagnosticsProperty<Animation<double>>(
        'placeholderOpacity', _placeholderOpacityAnimation));
  }
}
