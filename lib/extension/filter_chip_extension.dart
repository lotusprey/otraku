import 'package:flutter/material.dart';

extension FilterChipExtension on FilterChip {
  static final highContrast = (bool highContrast) =>
      highContrast ? FilterChip.new : FilterChip.elevated;
}
