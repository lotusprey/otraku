import 'package:flutter/material.dart';
import 'package:otraku/common/widgets/fields/labeled_field.dart';
import 'package:otraku/common/widgets/fields/number_field.dart';

const _minYear = 1930;

class YearRangePicker extends StatefulWidget {
  const YearRangePicker({
    required this.title,
    required this.from,
    required this.to,
    required this.onChanged,
  });

  final String title;
  final int? from;
  final int? to;
  final void Function(int?, int?) onChanged;

  @override
  State<YearRangePicker> createState() => _YearRangePickerState();
}

class _YearRangePickerState extends State<YearRangePicker> {
  late int _maxYear;
  late int _from;
  late int _to;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void didUpdateWidget(covariant YearRangePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    _init();
  }

  void _init() {
    _maxYear = DateTime.now().year + 1;
    _from = widget.from ?? _minYear;
    _to = widget.to ?? _maxYear;
    if (_from < _minYear) _from = _minYear;
    if (_to > _maxYear) _to = _maxYear;
    if (_from > _to) _from = _to;
  }

  @override
  Widget build(BuildContext context) {
    return LabeledField(
      label: widget.title,
      child: Row(
        children: [
          Flexible(
            child: NumberField(
              value: _from,
              minValue: _minYear,
              maxValue: _maxYear,
              onChanged: (from) {
                setState(() {
                  _from = from;
                  if (_to < _from) _to = _from;
                });

                _from > _minYear || _to < _maxYear
                    ? widget.onChanged(_from, _to)
                    : widget.onChanged(null, null);
              },
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: NumberField(
              value: _to,
              minValue: _minYear,
              maxValue: _maxYear,
              onChanged: (to) {
                setState(() {
                  _to = to;
                  if (_from > _to) _from = _to;
                });

                _from > _minYear || _to < _maxYear
                    ? widget.onChanged(_from, _to)
                    : widget.onChanged(null, null);
              },
            ),
          ),
        ],
      ),
    );
  }
}
