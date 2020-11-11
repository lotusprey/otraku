import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:otraku/controllers/app_config.dart';

class NumberField extends StatefulWidget {
  final int initialValue;
  final int maxValue;
  final int fraction;
  final Function(int) update;

  NumberField({
    @required this.update,
    this.initialValue = 0,
    this.maxValue,
    this.fraction = 1,
  });

  @override
  _NumberFieldState createState() => _NumberFieldState();
}

class _NumberFieldState extends State<NumberField> {
  TextEditingController _controller;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: AppConfig.BORDER_RADIUS,
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove),
              onPressed: () => _validateInput(add: -widget.fraction),
            ),
            Expanded(
              child: TextField(
                controller: _controller,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                ],
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyText1,
                cursorColor: Theme.of(context).accentColor,
                decoration: const InputDecoration(border: InputBorder.none),
                onChanged: (value) => _validateInput(),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _validateInput(add: widget.fraction),
            ),
          ],
        ),
      );

  void _validateInput({int add = 0}) {
    int result;

    if (_controller.text == null || _controller.text == '') {
      result = 0;
    } else {
      int number = int.parse(_controller.text) + add;

      if (widget.maxValue != null && number > widget.maxValue) {
        result = widget.maxValue;
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
  }

  @override
  void dispose() {
    _controller.removeListener(_validateInput);
    _controller.dispose();
    super.dispose();
  }
}
