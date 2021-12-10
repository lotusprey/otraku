import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/constants/consts.dart';
import 'package:otraku/utils/theming.dart';

class CheckBoxField extends StatefulWidget {
  final String title;
  final bool initial;
  final void Function(bool) onChanged;

  const CheckBoxField({
    required this.title,
    required this.initial,
    required this.onChanged,
  });

  @override
  _CheckBoxFieldState createState() => _CheckBoxFieldState();
}

class _CheckBoxFieldState extends State<CheckBoxField> {
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
      height: Consts.MATERIAL_TAP_TARGET_SIZE,
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
              width: Theming.ICON_BIG,
              height: Theming.ICON_BIG,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _on ? Theme.of(context).colorScheme.secondary : null,
                border: Border.all(
                  color: _on
                      ? Colors.transparent
                      : Theme.of(context).colorScheme.primary,
                  width: 2,
                ),
              ),
              child: _on
                  ? Icon(
                      Ionicons.checkmark_outline,
                      color: Theme.of(context).colorScheme.background,
                      size: Theming.ICON_SMALL,
                    )
                  : null,
            ),
            Expanded(
              child: Text(
                widget.title,
                style: _on
                    ? Theme.of(context).textTheme.bodyText2
                    : Theme.of(context).textTheme.subtitle1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
