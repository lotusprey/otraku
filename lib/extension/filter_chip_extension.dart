import 'package:material_ui/material_ui.dart';

extension FilterChipExtension on FilterChip {
  static final highContrast = (bool highContrast) =>
      highContrast ? FilterChip.new : FilterChip.elevated;
}
