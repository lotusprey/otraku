import 'package:flutter/material.dart';
import 'package:otraku/providers/theming.dart';

enum ScoreFormat {
  POINT_100,
  POINT_10_DECIMAL,
  POINT_10,
  POINT_5,
  POINT_3,
}

extension ScoreFormatExtension on ScoreFormat {
  static const _formats = {
    ScoreFormat.POINT_100: 'POINT_100',
    ScoreFormat.POINT_10_DECIMAL: 'POINT_10_DECIMAL',
    ScoreFormat.POINT_10: 'POINT_10',
    ScoreFormat.POINT_5: 'POINT_5',
    ScoreFormat.POINT_3: 'POINT_3',
  };

  String get string {
    return _formats[this];
  }
}

// ScoreFormat getScoreFormatFromString(String format) {
//   switch (format) {
//     case 'POINT_100':
//       return ScoreFormat.POINT_100;
//     case 'POINT_10_DECIMAL':
//       return ScoreFormat.POINT_10_DECIMAL;
//     case 'POINT_10':
//       return ScoreFormat.POINT_10;
//     case 'POINT_5':
//       return ScoreFormat.POINT_5;
//     case 'POINT_3':
//       return ScoreFormat.POINT_3;
//     default:
//       throw 'Could not formulate score format from string';
//   }
// }

Widget getWidgetFormScoreFormat(
  Palette palette,
  String format,
  double score,
) {
  if (score == 0) {
    return Text('');
  }

  switch (format) {
    case 'POINT_100':
    case 'POINT_10':
      return Text(
        score.toStringAsFixed(0),
        style: palette.detail,
      );
    case 'POINT_10_DECIMAL':
      return Text(
        score.toStringAsFixed(score.truncate() == score ? 0 : 1),
        style: palette.detail,
      );
    case 'POINT_5':
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            score.toStringAsFixed(0),
            style: palette.detail,
          ),
          Icon(Icons.star, size: Palette.ICON_SMALL, color: palette.faded),
        ],
      );
    case 'POINT_3':
      if (score == 3) {
        return Icon(
          Icons.sentiment_very_satisfied,
          size: Palette.ICON_MEDIUM,
          color: palette.faded,
        );
      }
      if (score == 2) {
        return Icon(
          Icons.sentiment_neutral,
          size: Palette.ICON_MEDIUM,
          color: palette.faded,
        );
      }
      return Icon(
        Icons.sentiment_very_dissatisfied,
        size: Palette.ICON_MEDIUM,
        color: palette.faded,
      );
    default:
      throw 'Unrecognised Score Format: $format';
  }
}
