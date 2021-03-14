import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otraku/controllers/viewer.dart';
import 'package:otraku/models/entry_model.dart';
import 'package:otraku/utils/config.dart';
import 'package:otraku/widgets/fields/number_field.dart';

class ScorePicker extends StatelessWidget {
  final EntryModel data;
  ScorePicker(this.data);

  @override
  Widget build(BuildContext context) {
    switch (describeEnum(Get.find<Viewer>().settings!.scoreFormat!)) {
      case 'POINT_3':
        return _SmileyScorePicker(data);
      case 'POINT_5':
        return _StarScorePicker(data);
      case 'POINT_10':
        return _TenScorePicker(data);
      case 'POINT_10_DECIMAL':
        return _TenDecimalScorePicker(data);
      default:
        return _HundredScorePicker(data);
    }
  }
}

class _SmileyScorePicker extends StatefulWidget {
  final EntryModel data;
  _SmileyScorePicker(this.data);

  @override
  __SmileyScorePickerState createState() => __SmileyScorePickerState();
}

class __SmileyScorePickerState extends State<_SmileyScorePicker> {
  Widget _face(int score, int index, Icon icon) {
    return IconButton(
      icon: icon,
      color: score == index
          ? Theme.of(context).accentColor
          : Theme.of(context).disabledColor,
      onPressed: () => score == index
          ? setState(() => widget.data.score = 0)
          : setState(() => widget.data.score = index.toDouble()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final score = widget.data.score.floor();

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: Config.BORDER_RADIUS,
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
  final EntryModel data;
  _StarScorePicker(this.data);

  @override
  __StarScorePickerState createState() => __StarScorePickerState();
}

class __StarScorePickerState extends State<_StarScorePicker> {
  Widget _star(int score, int index) {
    return IconButton(
      icon: score >= index
          ? const Icon(Icons.star)
          : const Icon(Icons.star_border),
      color: Theme.of(context).accentColor,
      onPressed: () => score != index
          ? setState(() => widget.data.score = index.toDouble())
          : setState(() => widget.data.score = 0),
    );
  }

  @override
  Widget build(BuildContext context) {
    final score = widget.data.score.floor();

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: Config.BORDER_RADIUS,
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
  final EntryModel data;
  _TenScorePicker(this.data);

  @override
  _TenScorePickerState createState() => _TenScorePickerState();
}

class _TenScorePickerState extends State<_TenScorePicker> {
  @override
  Widget build(BuildContext context) {
    final score = widget.data.score.truncateToDouble();

    return Row(
      children: [
        Expanded(
          child: Slider.adaptive(
            value: score,
            onChanged: (value) => setState(() => widget.data.score = value),
            min: 0,
            max: 10,
            divisions: 10,
          ),
        ),
        SizedBox(
          width: 30,
          child: Text(
            score.toStringAsFixed(0),
            style: Theme.of(context).textTheme.bodyText1,
          ),
        ),
      ],
    );
  }
}

class _TenDecimalScorePicker extends StatefulWidget {
  final EntryModel data;
  _TenDecimalScorePicker(this.data);

  @override
  _TenDecimalScorePickerState createState() => _TenDecimalScorePickerState();
}

class _TenDecimalScorePickerState extends State<_TenDecimalScorePicker> {
  @override
  Widget build(BuildContext context) {
    final score = widget.data.score;

    return Row(
      children: [
        Expanded(
          child: Slider.adaptive(
            value: score,
            onChanged: (value) => setState(() => widget.data.score = value),
            min: 0,
            max: 10,
            divisions: 100,
          ),
        ),
        SizedBox(
          width: 40,
          child: Text(
            score.toStringAsFixed(1),
            style: Theme.of(context).textTheme.bodyText1,
          ),
        ),
      ],
    );
  }
}

class _HundredScorePicker extends StatelessWidget {
  final EntryModel data;
  _HundredScorePicker(this.data);

  @override
  Widget build(BuildContext context) => NumberField(
        initialValue: data.score.floor(),
        maxValue: 100,
        update: (value) => data.score = value.toDouble(),
      );
}
