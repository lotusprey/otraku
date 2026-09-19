import 'package:material_ui/material_ui.dart';

extension CardExtension on Card {
  static final highContrast = (bool highContrast) => highContrast ? Card.outlined : Card.new;
}
