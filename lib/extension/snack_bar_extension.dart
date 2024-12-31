import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

extension SnackBarExtension on SnackBar {
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> show(
    BuildContext context,
    String text, {
    bool canCopyText = false,
  }) {
    return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(text),
      behavior: SnackBarBehavior.floating,
      action: canCopyText
          ? SnackBarAction(
              label: 'Copy',
              onPressed: () => Clipboard.setData(ClipboardData(text: text)),
            )
          : null,
    ));
  }

  /// Copy [text] to clipboard and notify with a snackbar.
  static void copy(BuildContext context, String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) show(context, 'Copied');
  }

  /// Launch [link] in the browser or show a snackbar if unsuccessful.
  static Future<bool> launch(BuildContext context, String link) async {
    try {
      final ok = await launchUrl(
        Uri.parse(link),
        mode: link.startsWith("https://anilist.co")
            ? LaunchMode.inAppBrowserView
            : LaunchMode.externalApplication,
      );

      if (ok) return true;
    } catch (_) {}

    if (context.mounted) show(context, 'Could not open link');
    return false;
  }
}
