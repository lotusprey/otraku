import 'package:material_ui/material_ui.dart';

extension ChoiceChipExtension on ChoiceChip {
  static final highContrast = (bool highContrast) =>
      highContrast ? ChoiceChip.new : ChoiceChip.elevated;
}
