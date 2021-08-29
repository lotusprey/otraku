import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/utils/config.dart';
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
  late bool _val;

  @override
  void initState() {
    super.initState();
    _val = widget.initial;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: Config.MATERIAL_TAP_TARGET_SIZE,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          Feedback.forTap(context);
          setState(() => _val = !_val);
          widget.onChanged(_val);
        },
        child: Row(
          children: [
            Expanded(child: Text(widget.title)),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: Theming.ICON_BIG,
              height: Theming.ICON_BIG,
              margin: const EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _val ? Theme.of(context).colorScheme.secondary : null,
                border: Border.all(
                  color: _val
                      ? Colors.transparent
                      : Theme.of(context).colorScheme.primary,
                  width: 2,
                ),
              ),
              child: _val
                  ? Icon(
                      Ionicons.checkmark_outline,
                      color: Theme.of(context).colorScheme.background,
                      size: Theming.ICON_SMALL,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
