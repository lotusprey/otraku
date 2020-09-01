import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:otraku/providers/theming.dart';

class NumberField extends StatefulWidget {
  final Palette palette;
  final int initialValue;
  final int maxValue;

  NumberField({
    @required this.palette,
    this.initialValue = 0,
    this.maxValue,
  });

  @override
  _NumberFieldState createState() => _NumberFieldState();
}

class _NumberFieldState extends State<NumberField> {
  TextEditingController _controller;
  int _maxValue;
  String _currentValue;

  @override
  Widget build(BuildContext context) {
    _controller.text = _currentValue;

    return SizedBox(
      height: 40,
      child: TextFormField(
        controller: _controller,
        keyboardType: TextInputType.number,
        inputFormatters: [
          WhitelistingTextInputFormatter.digitsOnly,
        ],
        textAlign: TextAlign.center,
        textAlignVertical: TextAlignVertical.top,
        style: widget.palette.paragraph,
        cursorColor: widget.palette.accent,
        enableInteractiveSelection: false,
        decoration: InputDecoration(
          border: InputBorder.none,
          prefixIcon: IconButton(
            icon: const Icon(Icons.remove),
            iconSize: Palette.ICON_SMALL,
            color: widget.palette.faded,
            onPressed: () => _validateInput(add: -1),
          ),
          suffixIcon: IconButton(
            icon: const Icon(Icons.add),
            iconSize: Palette.ICON_SMALL,
            color: widget.palette.faded,
            onPressed: () => _validateInput(add: 1),
          ),
        ),
        onChanged: (value) => _validateInput(),
      ),
    );
  }

  void _validateInput({int add = 0}) {
    if (_controller.text == '') {
      setState(() => _currentValue = '0');
    } else {
      int number = int.parse(_controller.text) + add;
      if (number > _maxValue) {
        setState(() => _currentValue = _maxValue.toString());
      } else if (number < 0) {
        setState(() => _currentValue = '0');
      } else {
        setState(() => _currentValue = number.toString());
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _currentValue = widget.initialValue.toString();
    _maxValue = widget.maxValue ?? 10000;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
