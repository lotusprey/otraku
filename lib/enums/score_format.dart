import 'package:flutter/material.dart';
import 'package:otraku/enums/themes.dart';

enum ScoreFormat {
  POINT_100,
  POINT_10_DECIMAL,
  POINT_10,
  POINT_5,
  POINT_3,
}

extension ScoreFormatExtension on ScoreFormat {
  Widget getWidget(final BuildContext ctx, final double score) {
    if (score == 0) return const SizedBox();

    switch (this) {
      case ScoreFormat.POINT_3:
        if (score == 3)
          return const Icon(
            Icons.sentiment_very_satisfied,
            size: Style.ICON_SMALL,
          );
        if (score == 2)
          return const Icon(Icons.sentiment_neutral, size: Style.ICON_SMALL);
        return const Icon(
          Icons.sentiment_very_dissatisfied,
          size: Style.ICON_SMALL,
        );
      case ScoreFormat.POINT_5:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star_rounded, size: Style.ICON_SMALL),
            const SizedBox(width: 5),
            Text(
              score.toStringAsFixed(0),
              style: Theme.of(ctx).textTheme.subtitle1,
            ),
          ],
        );
      case ScoreFormat.POINT_10_DECIMAL:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star_half_rounded, size: Style.ICON_SMALL),
            const SizedBox(width: 5),
            Text(
              score.toStringAsFixed(score.truncate() == score ? 0 : 1),
              style: Theme.of(ctx).textTheme.subtitle1,
            ),
          ],
        );
      default:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star_half_rounded, size: Style.ICON_SMALL),
            const SizedBox(width: 5),
            Text(
              score.toStringAsFixed(0),
              style: Theme.of(ctx).textTheme.subtitle1,
            ),
          ],
        );
    }
  }
}
