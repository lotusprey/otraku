import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:otraku/utils/config.dart';

class FadeImage extends StatelessWidget {
  final String image;
  final BoxFit fit;
  final double width;
  final double height;
  final Alignment alignment;

  FadeImage(
    this.image, {
    this.fit = BoxFit.cover,
    this.width = double.infinity,
    this.height = double.infinity,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return FadeInImage.memoryNetwork(
      fit: fit,
      image: image,
      width: width,
      height: height,
      alignment: alignment,
      fadeInDuration: Config.FADE_DURATION,
      fadeOutDuration: Config.FADE_DURATION,
      placeholder: _transparentImage,
      imageErrorBuilder: (_, err, stackTrace) => const SizedBox(),
    );
  }

  // A transparent image
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
