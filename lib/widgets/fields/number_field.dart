import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:otraku/constants/consts.dart';

class NumberField extends StatefulWidget {
  NumberField({required this.onChanged, this.initial = 0, this.maxValue});

  final num initial;
  final num? maxValue;
  final void Function(num) onChanged;

  @override
  _NumberFieldState createState() => _NumberFieldState();
}

class _NumberFieldState extends State<NumberField> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initial.toString());
  }

  @override
  void didUpdateWidget(covariant NumberField oldWidget) {
    super.didUpdateWidget(oldWidget);
    final text = widget.initial.toString();
    if (text != _ctrl.text)
      _ctrl.value = TextEditingValue(
        text: text,
        selection: TextSelection(
          baseOffset: text.length,
          extentOffset: text.length,
        ),
      );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: Consts.borderRadiusMin,
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove),
              onPressed: () => _validateInput(_ctrl.text, -1),
            ),
            Expanded(
              child: TextField(
                controller: _ctrl,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                ],
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyText2,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(0),
                ),
                onChanged: _validateInput,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _validateInput(_ctrl.text, 1),
            ),
          ],
        ),
      );

  void _validateInput(String value, [num add = 0]) {
    num result;
    bool needCursorReset = true;

    if (value.isEmpty)
      result = 0;
    else {
      final number = num.parse(value) + add;

      if (widget.maxValue != null && number > widget.maxValue!)
        result = widget.maxValue!;
      else if (number < 0)
        result = 0;
      else {
        result = number;
        if (add == 0 && int.tryParse(value) == null) needCursorReset = false;
      }
    }

    widget.onChanged(result);
    if (!needCursorReset) return;

    final text = result.toString();
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
