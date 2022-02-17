import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:otraku/constants/consts.dart';

class Toast {
  Toast._();

  static OverlayEntry? _entry;
  static bool _busy = false;

  static void show(final BuildContext context, final String text) {
    _busy = true;
    _entry?.remove();

    _entry = OverlayEntry(
      builder: (context) => Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          margin: EdgeInsets.only(
            bottom: 70 +
                MediaQuery.of(context).viewPadding.bottom +
                MediaQuery.of(context).viewInsets.bottom,
          ),
          padding: Consts.PADDING,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: Consts.BORDER_RAD_MIN,
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.background,
                blurRadius: 10,
              ),
            ],
          ),
          child: Text(text, style: Theme.of(context).textTheme.bodyText1),
        ),
      ),
    );

    Overlay.of(context)!.insert(_entry!);

    Future.delayed(const Duration(seconds: 2)).then((_) {
      if (!_busy) {
        _entry?.remove();
        _entry = null;
      }
    });

    _busy = false;
  }

  static void copy(final BuildContext context, final String text) =>
      Clipboard.setData(ClipboardData(text: text))
          .then((_) => show(context, 'Copied'));
}
