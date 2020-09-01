import 'package:flutter/material.dart';
import 'package:otraku/providers/theming.dart';

class GridChild extends StatelessWidget {
  static const _space = SizedBox(height: 5);

  final String title;
  final Widget body;
  final Palette palette;

  GridChild({
    @required this.title,
    @required this.body,
    @required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: palette.smallTitle,
          ),
          _space,
          body,
        ],
      ),
    );
  }
}
