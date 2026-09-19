import 'package:material_ui/material_ui.dart';

extension ActionChipExtension on ActionChip {
  static final highContrast = (bool highContrast) =>
      highContrast ? ActionChip.new : ActionChip.elevated;
}
