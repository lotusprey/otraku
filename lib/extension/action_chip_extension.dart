import 'package:flutter/material.dart';

extension ActionChipExtension on ActionChip {
  static final highContrast = (bool highContrast) =>
      highContrast ? ActionChip.new : ActionChip.elevated;
}
