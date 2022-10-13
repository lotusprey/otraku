import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/utils/consts.dart';

class CheckBoxField extends StatefulWidget {
  const CheckBoxField({
    required this.title,
    required this.initial,
    required this.onChanged,
  });

  final String title;
  final bool initial;
  final void Function(bool) onChanged;

  @override
  CheckBoxFieldState createState() => CheckBoxFieldState();
}

class CheckBoxFieldState extends State<CheckBoxField> {
  late bool _on;

  @override
  void initState() {
    super.initState();
    _on = widget.initial;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: Consts.tapTargetSize,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          Feedback.forTap(context);
          setState(() => _on = !_on);
          widget.onChanged(_on);
        },
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: Consts.iconBig,
              height: Consts.iconBig,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _on ? Theme.of(context).colorScheme.primary : null,
                border: Border.all(
                  color: _on
                      ? Colors.transparent
                      : Theme.of(context).colorScheme.surfaceVariant,
                  width: 2,
                ),
              ),
              child: _on
                  ? Icon(
                      Ionicons.checkmark_outline,
                      color: Theme.of(context).colorScheme.background,
                      size: Consts.iconSmall,
                    )
                  : null,
            ),
            Expanded(
              child: Text(
                widget.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyText2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CheckBoxTriField extends StatefulWidget {
  const CheckBoxTriField({
    required this.title,
    required this.initial,
    required this.onChanged,
    Key? key,
  })  : assert(initial > -2 && initial < 2),
        super(key: key);

  final String title;
  final int initial;
  final void Function(int) onChanged;

  @override
  CheckBoxTriFieldState createState() => CheckBoxTriFieldState();
}

class CheckBoxTriFieldState extends State<CheckBoxTriField> {
  late int _state;

  @override
  void initState() {
    super.initState();
    _state = widget.initial;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: Consts.tapTargetSize,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          Feedback.forTap(context);
          setState(() => _state < 1 ? _state++ : _state = -1);
          widget.onChanged(_state);
        },
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: Consts.iconBig,
              height: Consts.iconBig,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _state == 0
                    ? null
                    : _state == 1
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.error,
                border: Border.all(
                  color: _state != 0
                      ? Colors.transparent
                      : Theme.of(context).colorScheme.surfaceVariant,
                  width: 2,
                ),
              ),
              child: _state != 0
                  ? Icon(
                      _state == 1 ? Icons.add_rounded : Icons.remove_rounded,
                      color: Theme.of(context).colorScheme.background,
                      size: Consts.iconSmall,
                    )
                  : null,
            ),
            Expanded(
              child: Text(
                widget.title,
                style: Theme.of(context).textTheme.bodyText2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
