import 'package:flutter/material.dart';

const _minYear = 1960.0;

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
  late double _maxYear;
  late double _from;
  late double _to;

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
    _maxYear = DateTime.now().year.toDouble() + 1;
    _from = widget.from?.toDouble() ?? _minYear;
    _to = widget.to?.toDouble() ?? _maxYear;
    if (_from < _minYear) _from = _minYear;
    if (_to > _maxYear) _to = _maxYear;
    if (_from > _to) _from = _to;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10, top: 5),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(widget.title,
                  style: Theme.of(context).textTheme.labelMedium),
              const Spacer(),
              SizedBox(
                width: 50,
                child: Text(
                  _from.truncate().toString(),
                  textAlign: TextAlign.left,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              const Text(' - '),
              SizedBox(
                width: 50,
                child: Text(
                  _to.truncate().toString(),
                  textAlign: TextAlign.right,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: RangeSlider(
              values: RangeValues(_from, _to),
              min: _minYear,
              max: _maxYear,
              divisions: (_maxYear - _minYear + 1).truncate(),
              onChanged: (range) {
                setState(() {
                  _from = range.start;
                  _to = range.end;
                });

                _from > _minYear || _to < _maxYear
                    ? widget.onChanged(_from.truncate(), _to.truncate())
                    : widget.onChanged(null, null);
              },
            ),
          ),
        ],
      ),
    );
  }
}
