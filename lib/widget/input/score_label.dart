import 'package:flutter/material.dart';
import 'package:otraku/feature/media/media_models.dart';
import 'package:otraku/util/theming.dart';

class ScoreLabel extends StatelessWidget {
  const ScoreLabel(this.score, this.scoreFormat);

  final double score;
  final ScoreFormat scoreFormat;

  @override
  Widget build(BuildContext context) {
    if (score == 0) return const SizedBox();

    Widget content;
    switch (scoreFormat) {
      case .point3:
        if (score == 3) {
          content = const Icon(Icons.sentiment_very_satisfied, size: Theming.iconSmall);
        } else if (score == 2) {
          content = const Icon(Icons.sentiment_neutral, size: Theming.iconSmall);
        } else {
          content = const Icon(Icons.sentiment_very_dissatisfied, size: Theming.iconSmall);
        }
      case .point5:
        content = Row(
          mainAxisSize: .min,
          spacing: 3,
          children: [
            const Icon(Icons.star_rounded, size: Theming.iconSmall),
            Text('${score.toStringAsFixed(0)}/5', style: TextTheme.of(context).labelSmall),
          ],
        );
      case .point100:
        content = Row(
          mainAxisSize: .min,
          spacing: 3,
          children: [
            const Icon(Icons.star_rounded, size: Theming.iconSmall),
            Text('${score.toStringAsFixed(0)}/100', style: TextTheme.of(context).labelSmall),
          ],
        );
      case .point10:
        content = Row(
          mainAxisSize: .min,
          spacing: 3,
          children: [
            const Icon(Icons.star_rounded, size: Theming.iconSmall),
            Text('${score.toStringAsFixed(0)}/10', style: TextTheme.of(context).labelSmall),
          ],
        );
      case .point10Decimal:
        content = Row(
          mainAxisSize: .min,
          spacing: 3,
          children: [
            const Icon(Icons.star_rounded, size: Theming.iconSmall),
            Text('${score.toStringAsFixed(1)}/10.0', style: TextTheme.of(context).labelSmall),
          ],
        );
    }

    return Tooltip(message: 'Score', child: content);
  }
}
