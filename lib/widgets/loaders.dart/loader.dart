import 'package:flutter/material.dart';
import 'package:otraku/constants/consts.dart';
import 'package:otraku/widgets/loaders.dart/shimmer.dart';

class Loader extends StatelessWidget {
  const Loader();

  @override
  Widget build(BuildContext context) => Shimmer(ShimmerItem(
        Container(
          width: 60,
          height: 15,
          decoration: BoxDecoration(
            borderRadius: Consts.BORDER_RAD_MIN,
            color: Theme.of(context).colorScheme.surface,
          ),
        ),
      ));
}
