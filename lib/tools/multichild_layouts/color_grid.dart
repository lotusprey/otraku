import 'package:flutter/material.dart';
import 'package:otraku/providers/theming.dart';
import 'package:provider/provider.dart';

class ColorGrid extends StatelessWidget {
  final Palette palette;

  ColorGrid(this.palette);

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(5);

    return GridView.builder(
      shrinkWrap: true,
      itemCount: Accents.values.length,
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1,
        maxCrossAxisExtent: 60,
      ),
      itemBuilder: (ctx, index) {
        final accent = Accents.values[index].swatch.item1;

        return GestureDetector(
          child: Container(
            decoration: BoxDecoration(
              color: accent,
              borderRadius: radius,
            ),
            child: accent == palette.accent
                ? const Icon(
                    Icons.done,
                    size: Palette.ICON_BIG,
                    color: Colors.white,
                  )
                : null,
          ),
          onTap: () => Provider.of<Theming>(context, listen: false)
              .setAccent(Accents.values[index]),
        );
      },
    );
  }
}
