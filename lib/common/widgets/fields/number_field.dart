import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Input field for integer numbers with buttons on the side
/// to increment/decrement by 1.
class NumberField extends StatelessWidget {
  const NumberField({
    required this.onChanged,
    this.value = 0,
    this.minValue = 0,
    this.maxValue,
  });

  final int value;
  final int minValue;
  final int? maxValue;
  final void Function(int) onChanged;

  @override
  Widget build(BuildContext context) => _NumberField(
        value: value,
        minValue: minValue,
        stepValue: 1,
        maxValue: maxValue,
        isDecimal: false,
        onChanged: (n) => onChanged(n.toInt()),
      );
}

/// Input field for decimal numbers with buttons on the side
/// to increment/decrement by 0.5.
/// Only one digit after the decimal point will be registered.
class DecimalNumberField extends StatelessWidget {
  const DecimalNumberField({
    required this.onChanged,
    this.value = 0.0,
    this.minValue = 0.0,
    this.maxValue,
  });

  final double value;
  final double minValue;
  final double? maxValue;
  final void Function(double) onChanged;

  @override
  Widget build(BuildContext context) => _NumberField(
        value: value,
        minValue: minValue,
        stepValue: 0.5,
        maxValue: maxValue,
        isDecimal: true,
        onChanged: (n) => onChanged((n * 10).round() / 10),
      );
}

class _NumberField extends StatefulWidget {
  const _NumberField({
    required this.value,
    required this.minValue,
    required this.stepValue,
    required this.maxValue,
    required this.isDecimal,
    required this.onChanged,
  });

  final num value;
  final num minValue;
  final num stepValue;
  final num? maxValue;
  final bool isDecimal;
  final void Function(num) onChanged;

  @override
  _NumberFieldState createState() => _NumberFieldState();
}

class _NumberFieldState extends State<_NumberField> {
  late final _ctrl = TextEditingController(text: widget.value.toString());
  bool _isValid = true;

  @override
  void didUpdateWidget(covariant _NumberField oldWidget) {
    super.didUpdateWidget(oldWidget);
    final text = widget.value.toString();
    if (text != _ctrl.text) {
      _ctrl.value = TextEditingValue(
        text: text,
        selection: TextSelection(
          baseOffset: text.length,
          extentOffset: text.length,
        ),
      );
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Row(
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: Semantics(
              button: true,
              child: InkResponse(
                onTap: () => _validateInput(_ctrl.text, -widget.stepValue),
                radius: 10,
                child: Tooltip(
                  message: 'Decrement',
                  onTriggered: () => _validateInput(widget.minValue.toString()),
                  child: const Icon(Icons.remove),
                ),
              ),
            ),
          ),
          Expanded(
            child: TextField(
              controller: _ctrl,
              keyboardType: TextInputType.numberWithOptions(
                decimal: widget.isDecimal,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                  widget.isDecimal ? RegExp(r'^\d*\.?\d*$') : RegExp(r'\d*'),
                ),
              ],
              textAlign: TextAlign.center,
              style: _isValid
                  ? Theme.of(context).textTheme.bodyMedium
                  : Theme.of(context).textTheme.labelMedium,
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(0),
              ),
              onChanged: _validateInput,
            ),
          ),
          SizedBox(
            width: 40,
            height: 40,
            child: Semantics(
              button: true,
              child: InkResponse(
                onTap: () => _validateInput(_ctrl.text, widget.stepValue),
                radius: 10,
                child: Tooltip(
                  message: 'Increment',
                  onTriggered: () {
                    if (widget.maxValue == null) return;
                    _validateInput(widget.maxValue.toString());
                  },
                  child: const Icon(Icons.add),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _validateInput(String value, [num? add]) {
    if (value.isEmpty) return;

    num number = num.parse(value);
    if (add != null) number += add;

    // The value is allowed to go out of bounds while editing,
    // but it should not affect the real state.
    if (number < widget.minValue ||
        widget.maxValue != null && number > widget.maxValue!) {
      // Buttons can't make the field invalid, but manual edits can.
      if (_isValid && add == null) setState(() => _isValid = false);
      return;
    }

    if (!_isValid) setState(() => _isValid = true);
    widget.onChanged(number);

    // Unfinished decimal numbers like `4.` should not reset the field.
    if (int.tryParse(value) == null) return;

    final text = number.toString();
    _ctrl.value = _ctrl.value.copyWith(
      text: text,
      selection: TextSelection(
        baseOffset: text.length,
        extentOffset: text.length,
      ),
      composing: TextRange.empty,
    );
  }
}
