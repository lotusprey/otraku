import 'package:flutter/material.dart';
import 'package:otraku/feature/media/media_models.dart';
import 'package:otraku/util/theming.dart';

/// Score picker.
class ScoreField extends StatefulWidget {
  const ScoreField({required this.value, required this.scoreFormat, required this.onChanged});

  final double value;
  final ScoreFormat? scoreFormat;
  final void Function(double) onChanged;

  @override
  State<ScoreField> createState() => _ScoreFieldState();
}

class _ScoreFieldState extends State<ScoreField> {
  late var _value = widget.value;

  @override
  void didUpdateWidget(covariant ScoreField oldWidget) {
    super.didUpdateWidget(oldWidget);
    _value = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const .all(Theming.offset),
      child: InputDecorator(
        decoration: const InputDecoration(labelText: 'Score', border: OutlineInputBorder()),
        child: switch (widget.scoreFormat ?? .point10) {
          .point3 => _SmileyScorePicker(_value, _onChanged),
          .point5 => _StarScorePicker(_value, _onChanged),
          .point10 => _TenScorePicker(_value, _onChanged),
          .point10Decimal => _TenDecimalScorePicker(_value, _onChanged),
          .point100 => _HundredScorePicker(_value, _onChanged),
        },
      ),
    );
  }

  void _onChanged(double value) {
    setState(() => _value = value);
    widget.onChanged(value);
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
      mainAxisAlignment: .spaceEvenly,
      children: [
        for (final (i, icon, tooltip) in items)
          IconButton(
            tooltip: score.floor() != i ? tooltip : 'Unscore',
            iconSize: 30,
            icon: icon,
            color: score.floor() != i
                ? ColorScheme.of(context).surfaceContainerHighest
                : ColorScheme.of(context).primary,
            onPressed: () => score.floor() != i ? onChanged(i.toDouble()) : onChanged(0),
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
      mainAxisAlignment: .spaceEvenly,
      children: [
        for (int i = 1; i < 6; i++)
          IconButton(
            tooltip: score.floor() != i ? 'Score $i Stars' : 'Unscore',
            iconSize: 30,
            icon: score >= i
                ? const Icon(Icons.star_rounded)
                : const Icon(Icons.star_outline_rounded),
            color: ColorScheme.of(context).primary,
            onPressed: () => score.floor() != i ? onChanged(i.toDouble()) : onChanged(0),
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
