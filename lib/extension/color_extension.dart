import 'package:flutter/widgets.dart';

extension ColorExtension on Color {
  static Color? fromHexString(String src) {
    try {
      return Color(int.parse(src.substring(1, 7), radix: 16) + 0xFF000000);
    } catch (_) {
      return null;
    }
  }
}
