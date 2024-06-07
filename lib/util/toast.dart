import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:otraku/util/theming.dart';
import 'package:url_launcher/url_launcher.dart';

class Toast {
  Toast._();

  static OverlayEntry? _entry;
  static bool _busy = false;

  /// Present a toast message.
  static void show(BuildContext context, String text) {
    _busy = true;
    _entry?.remove();

    final bottomOffset = 70 +
        MediaQuery.viewPaddingOf(context).bottom +
        MediaQuery.viewInsetsOf(context).bottom;

    _entry = OverlayEntry(
      builder: (context) => Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          margin: EdgeInsets.only(
            bottom: bottomOffset,
          ),
          padding: Theming.paddingAll,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: Theming.borderRadiusSmall,
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.surface,
                blurRadius: 10,
              ),
            ],
          ),
          child: Text(text, style: Theme.of(context).textTheme.labelLarge),
        ),
      ),
    );

    Overlay.of(context).insert(_entry!);

    Future.delayed(const Duration(seconds: 2)).then((_) {
      if (!_busy) {
        _entry?.remove();
        _entry = null;
      }
    });

    _busy = false;
  }

  /// Copy [text] to clipboard and notify with a toast.
  static void copy(BuildContext context, String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) show(context, 'Copied');
  }

  /// Launch [link] in the browser or show a toast if unsuccessful.
  static Future<bool> launch(BuildContext context, String link) async {
    try {
      final ok = await launchUrl(
        Uri.parse(link),
        mode: LaunchMode.externalApplication,
      );

      if (ok) return true;
    } catch (_) {}

    if (context.mounted) show(context, 'Could not open link');
    return false;
  }
}
