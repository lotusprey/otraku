import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/modules/edit/edit_model.dart';
import 'package:otraku/modules/edit/edit_providers.dart';
import 'package:otraku/modules/media/media_constants.dart';
import 'package:otraku/modules/settings/settings_provider.dart';

/// Score picker.
class ScoreField extends StatelessWidget {
  const ScoreField(this.tag);

  final EditTag tag;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Score',
          border: OutlineInputBorder(),
        ),
        child: Consumer(
          builder: (context, ref, _) {
            final score = ref.watch(
              newEditProvider(tag).select((s) => s.score),
            );

            final scoreFormat =
                ref.watch(settingsProvider).valueOrNull?.scoreFormat ??
                    ScoreFormat.point10;

            final onChanged = (num v) => ref
                .read(newEditProvider(tag).notifier)
                .update((s) => s.copyWith(score: v.toDouble()));

            return switch (scoreFormat) {
              ScoreFormat.point3 => _SmileyScorePicker(score, onChanged),
              ScoreFormat.point5 => _StarScorePicker(score, onChanged),
              ScoreFormat.point10 => _TenScorePicker(score, onChanged),
              ScoreFormat.point10Decimal =>
                _TenDecimalScorePicker(score, onChanged),
              ScoreFormat.point100 => _HundredScorePicker(score, onChanged),
            };
          },
        ),
      ),
    );
  }
}

class _SmileyScorePicker extends StatelessWidget {
  const _SmileyScorePicker(this.score, this.onChanged);

  final double score;
  final void Function(double) onChanged;

  @override
  Widget build(BuildContext context) {
    const items = [
      (1, Icon(Icons.sentiment_very_dissatisfied), 'Score Disliked'),
      (2, Icon(Icons.sentiment_neutral), 'Score Neutral'),
      (3, Icon(Icons.sentiment_very_satisfied), 'Score Liked'),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        for (final (i, icon, tooltip) in items)
          IconButton(
            tooltip: score.floor() != i ? tooltip : 'Unscore',
            iconSize: 30,
            icon: icon,
            color: score.floor() != i
                ? Theme.of(context).colorScheme.surfaceVariant
                : Theme.of(context).colorScheme.primary,
            onPressed: () =>
                score.floor() != i ? onChanged(i.toDouble()) : onChanged(0),
          ),
      ],
    );
  }
}

class _StarScorePicker extends StatelessWidget {
  const _StarScorePicker(this.score, this.onChanged);

  final double score;
  final void Function(double) onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        for (int i = 1; i < 6; i++)
          IconButton(
            tooltip: score.floor() != i ? 'Score $i Stars' : 'Unscore',
            iconSize: 30,
            icon: score >= i
                ? const Icon(Icons.star_rounded)
                : const Icon(Icons.star_outline_rounded),
            color: Theme.of(context).colorScheme.primary,
            onPressed: () =>
                score.floor() != i ? onChanged(i.toDouble()) : onChanged(0),
          ),
      ],
    );
  }
}

class _TenScorePicker extends StatelessWidget {
  const _TenScorePicker(this.score, this.onChanged);

  final double score;
  final void Function(double) onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Slider.adaptive(
            value: score.truncateToDouble(),
            onChanged: onChanged,
            min: 0,
            max: 10,
            divisions: 10,
          ),
        ),
        SizedBox(width: 30, child: Text(score.toStringAsFixed(0))),
      ],
    );
  }
}

class _TenDecimalScorePicker extends StatelessWidget {
  const _TenDecimalScorePicker(this.score, this.onChanged);

  final double score;
  final void Function(double) onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Slider.adaptive(
            value: score,
            onChanged: (v) => onChanged((v * 10).round() / 10),
            min: 0,
            max: 10,
            divisions: 100,
          ),
        ),
        SizedBox(width: 40, child: Text(score.toStringAsFixed(1))),
      ],
    );
  }
}

class _HundredScorePicker extends StatelessWidget {
  const _HundredScorePicker(this.score, this.onChanged);

  final double score;
  final void Function(double) onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Slider.adaptive(
            value: score,
            onChanged: onChanged,
            min: 0,
            max: 100,
            divisions: 100,
          ),
        ),
        SizedBox(width: 30, child: Text(score.toStringAsFixed(0))),
      ],
    );
  }
}
