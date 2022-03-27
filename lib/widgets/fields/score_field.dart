import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otraku/constants/score_format.dart';
import 'package:otraku/controllers/home_controller.dart';
import 'package:otraku/models/edit_model.dart';
import 'package:otraku/constants/consts.dart';
import 'package:otraku/widgets/fields/number_field.dart';

// Score picker.
class ScoreField extends StatelessWidget {
  ScoreField(this.model);

  final EditModel model;

  @override
  Widget build(BuildContext context) {
    switch (Get.find<HomeController>().siteSettings?.scoreFormat) {
      case ScoreFormat.POINT_3:
        return _SmileyScorePicker(model);
      case ScoreFormat.POINT_5:
        return _StarScorePicker(model);
      case ScoreFormat.POINT_10:
        return _TenScorePicker(model);
      case ScoreFormat.POINT_10_DECIMAL:
        return _TenDecimalScorePicker(model);
      default:
        return _HundredScorePicker(model);
    }
  }
}

class _SmileyScorePicker extends StatefulWidget {
  _SmileyScorePicker(this.model);

  final EditModel model;

  @override
  __SmileyScorePickerState createState() => __SmileyScorePickerState();
}

class __SmileyScorePickerState extends State<_SmileyScorePicker> {
  Widget _face(int score, int index, Icon icon) {
    return IconButton(
      icon: icon,
      color: score == index
          ? Theme.of(context).colorScheme.secondary
          : Theme.of(context).colorScheme.primary,
      onPressed: () => score == index
          ? setState(() => widget.model.score = 0)
          : setState(() => widget.model.score = index.toDouble()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final score = widget.model.score.floor();

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: Consts.BORDER_RAD_MIN,
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
  _StarScorePicker(this.model);

  final EditModel model;

  @override
  __StarScorePickerState createState() => __StarScorePickerState();
}

class __StarScorePickerState extends State<_StarScorePicker> {
  Widget _star(int score, int index) {
    return IconButton(
      icon: score >= index
          ? const Icon(Icons.star)
          : const Icon(Icons.star_border),
      color: Theme.of(context).colorScheme.secondary,
      onPressed: () => score != index
          ? setState(() => widget.model.score = index.toDouble())
          : setState(() => widget.model.score = 0),
    );
  }

  @override
  Widget build(BuildContext context) {
    final score = widget.model.score.floor();

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: Consts.BORDER_RAD_MIN,
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
  _TenScorePicker(this.model);

  final EditModel model;

  @override
  _TenScorePickerState createState() => _TenScorePickerState();
}

class _TenScorePickerState extends State<_TenScorePicker> {
  @override
  Widget build(BuildContext context) {
    final score = widget.model.score.truncateToDouble();

    return Row(
      children: [
        Expanded(
          child: Slider.adaptive(
            value: score,
            onChanged: (val) => setState(() => widget.model.score = val),
            min: 0,
            max: 10,
            divisions: 10,
          ),
        ),
        SizedBox(
          width: 30,
          child: Text(score.toStringAsFixed(0)),
        ),
      ],
    );
  }
}

class _TenDecimalScorePicker extends StatefulWidget {
  _TenDecimalScorePicker(this.model);

  final EditModel model;

  @override
  _TenDecimalScorePickerState createState() => _TenDecimalScorePickerState();
}

class _TenDecimalScorePickerState extends State<_TenDecimalScorePicker> {
  @override
  Widget build(BuildContext context) {
    final score = widget.model.score;

    return Row(
      children: [
        Expanded(
          child: Slider.adaptive(
            value: score,
            onChanged: (val) =>
                setState(() => widget.model.score = val.toPrecision(1)),
            min: 0,
            max: 10,
            divisions: 100,
          ),
        ),
        SizedBox(
          width: 40,
          child: Text(score.toStringAsFixed(1)),
        ),
      ],
    );
  }
}

class _HundredScorePicker extends StatelessWidget {
  _HundredScorePicker(this.model);

  final EditModel model;

  @override
  Widget build(BuildContext context) => NumberField(
        value: model.score.floor(),
        maxValue: 100,
        update: (val) => model.score = val.toDouble(),
      );
}
