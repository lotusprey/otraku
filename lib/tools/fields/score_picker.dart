import 'package:flutter/material.dart';
import 'package:otraku/models/entry_user_data.dart';
import 'package:otraku/providers/anime_collection.dart';
import 'package:otraku/providers/theming.dart';
import 'package:otraku/providers/view_config.dart';
import 'package:otraku/tools/fields/number_field.dart';
import 'package:provider/provider.dart';

class ScorePicker extends StatelessWidget {
  final EntryUserData data;

  ScorePicker(this.data);

  @override
  Widget build(BuildContext context) {
    String scoreFormat =
        Provider.of<AnimeCollection>(context, listen: false).scoreFormat;
    Palette palette = Provider.of<Theming>(context, listen: false).palette;

    switch (scoreFormat) {
      case 'POINT_3':
        return _SmileyScorePicker(data, palette);
      case 'POINT_5':
        return _StarScorePicker(data, palette);
      case 'POINT_10':
        return _TenScorePicker(data, palette);
      case 'POINT_10_DECIMAL':
        return _TenDecimalScorePicker(data, palette);
      default:
        return _HundredScorePicker(data, palette);
    }
  }
}

class _SmileyScorePicker extends StatefulWidget {
  final EntryUserData data;
  final Palette palette;

  _SmileyScorePicker(this.data, this.palette);

  @override
  __SmileyScorePickerState createState() => __SmileyScorePickerState();
}

class __SmileyScorePickerState extends State<_SmileyScorePicker> {
  Widget _face(int score, int index, Icon icon) {
    return IconButton(
      icon: icon,
      color: score == index ? widget.palette.accent : widget.palette.faded,
      iconSize: Palette.ICON_MEDIUM,
      onPressed: () {
        if (score == index) {
          setState(() => widget.data.score = 0);
        } else {
          setState(() => widget.data.score = index.toDouble());
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    int score = widget.data.score.floor();

    return Container(
      decoration: BoxDecoration(
        color: widget.palette.foreground,
        borderRadius: ViewConfig.RADIUS,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _face(score, 1, const Icon(Icons.sentiment_very_dissatisfied)),
          _face(score, 2, const Icon(Icons.sentiment_neutral)),
          _face(score, 3, const Icon(Icons.sentiment_very_satisfied)),
        ],
      ),
    );
  }
}

class _StarScorePicker extends StatefulWidget {
  final EntryUserData data;
  final Palette palette;

  _StarScorePicker(this.data, this.palette);

  @override
  __StarScorePickerState createState() => __StarScorePickerState();
}

class __StarScorePickerState extends State<_StarScorePicker> {
  Widget _star(int score, int index) {
    return IconButton(
      icon: score >= index
          ? const Icon(Icons.star)
          : const Icon(Icons.star_border),
      color: widget.palette.accent,
      iconSize: Palette.ICON_MEDIUM,
      onPressed: () {
        if (score > index || score < index) {
          setState(() => widget.data.score = index.toDouble());
        } else {
          setState(() => widget.data.score = 0);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    int score = widget.data.score.floor();

    return Container(
      decoration: BoxDecoration(
        color: widget.palette.foreground,
        borderRadius: ViewConfig.RADIUS,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _star(score, 1),
          _star(score, 2),
          _star(score, 3),
          _star(score, 4),
          _star(score, 5),
        ],
      ),
    );
  }
}

class _TenScorePicker extends StatefulWidget {
  final EntryUserData data;
  final Palette palette;

  _TenScorePicker(this.data, this.palette);

  @override
  _TenScorePickerState createState() => _TenScorePickerState();
}

class _TenScorePickerState extends State<_TenScorePicker> {
  @override
  Widget build(BuildContext context) {
    double score = widget.data.score.truncateToDouble();

    return Slider.adaptive(
      value: score,
      onChanged: (value) => setState(() => widget.data.score = value),
      min: 0,
      max: 10,
      divisions: 10,
      label: score.toStringAsFixed(0),
      activeColor: widget.palette.accent,
      inactiveColor: widget.palette.foreground,
    );
  }
}

class _TenDecimalScorePicker extends StatefulWidget {
  final EntryUserData data;
  final Palette palette;

  _TenDecimalScorePicker(this.data, this.palette);

  @override
  _TenDecimalScorePickerState createState() => _TenDecimalScorePickerState();
}

class _TenDecimalScorePickerState extends State<_TenDecimalScorePicker> {
  @override
  Widget build(BuildContext context) {
    double score = widget.data.score;

    return Slider.adaptive(
      value: score,
      onChanged: (value) => setState(() => widget.data.score = value),
      min: 0,
      max: 10,
      divisions: 20,
      label: score.toString(),
      activeColor: widget.palette.accent,
      inactiveColor: widget.palette.foreground,
    );
  }
}

class _HundredScorePicker extends StatelessWidget {
  final EntryUserData data;
  final Palette palette;

  _HundredScorePicker(this.data, this.palette);

  @override
  Widget build(BuildContext context) {
    return NumberField(
      initialValue: data.score.floor(),
      maxValue: 100,
      update: (value) => data.score = value.toDouble(),
      palette: palette,
    );
  }
}
