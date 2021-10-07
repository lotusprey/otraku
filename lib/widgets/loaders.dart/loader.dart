import 'package:flutter/material.dart';
import 'package:otraku/utils/config.dart';
import 'package:otraku/widgets/loaders.dart/shimmer.dart';

class Loader extends StatelessWidget {
  const Loader();

  @override
  Widget build(BuildContext context) => Shimmer(ShimmerItem(
        Container(
          width: 60,
          height: 15,
          decoration: BoxDecoration(
            borderRadius: Config.BORDER_RADIUS,
            color: Theme.of(context).colorScheme.surface,
          ),
        ),
      ));
}
