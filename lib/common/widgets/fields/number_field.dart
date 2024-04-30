import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NumberField extends StatefulWidget {
  const NumberField._({
    required this.label,
    required this.value,
    required this.minValue,
    required this.stepValue,
    required this.maxValue,
    required this.onChanged,
    required this.isDecimal,
  });

  factory NumberField({
    required String label,
    required void Function(int) onChanged,
    int value = 0,
    int minValue = 0,
    int? maxValue,
  }) =>
      NumberField._(
        label: label,
        value: value,
        minValue: minValue,
        stepValue: 1,
        maxValue: maxValue,
        onChanged: (n) => onChanged(n.toInt()),
        isDecimal: false,
      );

  factory NumberField.decimal({
    required String label,
    required void Function(double) onChanged,
    double value = 0.0,
    double minValue = 0.0,
    double? maxValue,
  }) =>
      NumberField._(
        label: label,
        value: value,
        minValue: minValue,
        stepValue: 0.5,
        maxValue: maxValue,
        onChanged: (n) => onChanged((n * 10).round() / 10),
        isDecimal: true,
      );

  final String label;
  final num value;
  final num minValue;
  final num stepValue;
  final num? maxValue;
  final void Function(num) onChanged;
  final bool isDecimal;

  @override
  State<NumberField> createState() => _NumberFieldState();
}

class _NumberFieldState extends State<NumberField> {
  late final _ctrl = TextEditingController(text: widget.value.toString());
  String? _error;

  @override
  void didUpdateWidget(covariant NumberField oldWidget) {
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
    return TextField(
      controller: _ctrl,
      onChanged: _validateInput,
      textAlign: TextAlign.center,
      keyboardType: TextInputType.numberWithOptions(decimal: widget.isDecimal),
      inputFormatters: [
        FilteringTextInputFormatter.allow(
          widget.isDecimal ? RegExp(r'^\d*\.?\d?$') : RegExp(r'\d*'),
        ),
      ],
      decoration: InputDecoration(
        labelText: widget.label,
        errorText: _error,
        border: const OutlineInputBorder(),
        prefixIcon: Semantics(
          button: true,
          child: Material(
            color: Colors.transparent,
            child: InkResponse(
              onTap: () => _validateInput(_ctrl.text, -widget.stepValue),
              radius: 10,
              child: Tooltip(
                message: 'Decrement',
                onTriggered: () => _validateInput(
                  widget.minValue.toString(),
                  0,
                ),
                child: const Icon(Icons.remove),
              ),
            ),
          ),
        ),
        suffixIcon: Semantics(
          button: true,
          child: Material(
            color: Colors.transparent,
            child: InkResponse(
              onTap: () => _validateInput(_ctrl.text, widget.stepValue),
              radius: 10,
              child: Tooltip(
                message: 'Increment',
                onTriggered: () {
                  if (widget.maxValue == null) return;
                  _validateInput(widget.maxValue.toString(), 0);
                },
                child: const Icon(Icons.add),
              ),
            ),
          ),
        ),
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
      if (_error == null && add == null) {
        setState(
          () => number < widget.minValue
              ? _error = 'Minimum ${widget.minValue}'
              : _error = 'Maximum ${widget.maxValue}',
        );
      }
      return;
    }

    if (_error != null) setState(() => _error = null);
    widget.onChanged(number);

    // If the field was changed manually, it shouldn't erase an unfinished edit.
    if (add == null) return;

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
