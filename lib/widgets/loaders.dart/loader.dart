import 'package:flutter/material.dart';
import 'package:otraku/utils/config.dart';
import 'package:otraku/widgets/loaders.dart/shimmer.dart';

class Loader extends StatelessWidget {
  const Loader();

  @override
  Widget build(BuildContext context) {
    final origin = HSLColor.fromColor(Theme.of(context).primaryColor);
    final lightness = origin.lightness;

    return Shimmer(
      child: Container(
        width: 60,
        height: 15,
        decoration: const BoxDecoration(
          borderRadius: Config.BORDER_RADIUS,
          color: Colors.white,
        ),
      ),
      primary: Theme.of(context).primaryColor,
      secondary: origin
          .withLightness(lightness < 0.5 ? lightness + 0.1 : lightness - 0.1)
          .toColor(),
    );
  }
}
