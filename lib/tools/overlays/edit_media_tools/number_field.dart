import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:otraku/providers/theming.dart';
import 'package:otraku/providers/view_config.dart';

class NumberField extends StatefulWidget {
  final Palette palette;
  final int initialValue;
  final int maxValue;
  final Function(int) update;

  NumberField({
    @required this.palette,
    @required this.update,
    this.initialValue = 0,
    this.maxValue,
  });

  @override
  _NumberFieldState createState() => _NumberFieldState();
}

class _NumberFieldState extends State<NumberField> {
  TextEditingController _controller;
  int _maxValue;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.palette.primary,
        borderRadius: ViewConfig.RADIUS,
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.remove, size: Palette.ICON_MEDIUM),
            color: widget.palette.faded,
            onPressed: () => _validateInput(add: -1),
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              inputFormatters: [
                WhitelistingTextInputFormatter.digitsOnly,
              ],
              textAlign: TextAlign.center,
              style: widget.palette.paragraph,
              cursorColor: widget.palette.accent,
              decoration: const InputDecoration(border: InputBorder.none),
              onChanged: (value) => _validateInput(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add, size: Palette.ICON_MEDIUM),
            color: widget.palette.faded,
            onPressed: () => _validateInput(add: 1),
          ),
        ],
      ),
    );
  }

  void _validateInput({int add = 0}) {
    int result;

    if (_controller.text == null || _controller.text == '') {
      result = 0;
    } else {
      int number = int.parse(_controller.text) + add;

      if (number > _maxValue) {
        result = _maxValue;
      } else if (number < 0) {
        result = 0;
      } else {
        result = number;
      }
    }

    widget.update(result);

    final text = result.toString();
    _controller.value = _controller.value.copyWith(
      text: text,
      selection: TextSelection(
        baseOffset: text.length,
        extentOffset: text.length,
      ),
      composing: TextRange.empty,
    );
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue.toString());
    _controller.addListener(_validateInput);
    _maxValue = widget.maxValue ?? 100000;
  }

  @override
  void dispose() {
    _controller.removeListener(_validateInput);
    _controller.dispose();
    super.dispose();
  }
}
