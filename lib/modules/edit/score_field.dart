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
    return Consumer(
      builder: (context, ref, _) {
        final score = ref.watch(newEditProvider(tag).select((s) => s.score));
        final scoreFormat =
            ref.watch(settingsProvider).valueOrNull?.scoreFormat ??
                ScoreFormat.POINT_10;

        final onChanged = (v) => ref
            .read(newEditProvider(tag).notifier)
            .update((s) => s.copyWith(score: v));

        return switch (scoreFormat) {
          ScoreFormat.POINT_3 => _SmileyScorePicker(score, onChanged),
          ScoreFormat.POINT_5 => _StarScorePicker(score, onChanged),
          ScoreFormat.POINT_10 => _TenScorePicker(score, onChanged),
          ScoreFormat.POINT_10_DECIMAL =>
            _TenDecimalScorePicker(score, onChanged),
          ScoreFormat.POINT_100 => _HundredScorePicker(score, onChanged),
        };
      },
    );
  }
}

class _SmileyScorePicker extends StatelessWidget {
  const _SmileyScorePicker(this.score, this.onChanged);

  final double score;
  final void Function(double) onChanged;

  Widget _face(BuildContext context, int index, Icon icon) {
    return IconButton(
      iconSize: 30,
      padding: const EdgeInsets.all(5),
      icon: icon,
      color: score.floor() != index
          ? Theme.of(context).colorScheme.surfaceVariant
          : Theme.of(context).colorScheme.primary,
      onPressed: () =>
          score.floor() != index ? onChanged(index.toDouble()) : onChanged(0),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _face(context, 1, const Icon(Icons.sentiment_very_dissatisfied)),
        _face(context, 2, const Icon(Icons.sentiment_neutral)),
        _face(context, 3, const Icon(Icons.sentiment_very_satisfied)),
      ],
    );
  }
}

class _StarScorePicker extends StatelessWidget {
  const _StarScorePicker(this.score, this.onChanged);

  final double score;
  final void Function(double) onChanged;

  Widget _star(BuildContext context, int index) {
    return IconButton(
      iconSize: 30,
      padding: const EdgeInsets.all(5),
      icon: score >= index
          ? const Icon(Icons.star_rounded)
          : const Icon(Icons.star_outline_rounded),
      color: Theme.of(context).colorScheme.primary,
      onPressed: () =>
          score.floor() != index ? onChanged(index.toDouble()) : onChanged(0),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _star(context, 1),
        _star(context, 2),
        _star(context, 3),
        _star(context, 4),
        _star(context, 5),
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
