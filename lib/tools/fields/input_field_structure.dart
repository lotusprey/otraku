import 'package:flutter/material.dart';
import 'package:otraku/providers/theming.dart';

class InputFieldStructure extends StatelessWidget {
  static const _space = SizedBox(height: 5);

  final String title;
  final Widget body;
  final Palette palette;
  final bool enforceHeight;

  InputFieldStructure({
    @required this.title,
    @required this.body,
    @required this.palette,
    this.enforceHeight = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: enforceHeight ? 75 : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: palette.detail,
          ),
          _space,
          body,
        ],
      ),
    );
  }
}
