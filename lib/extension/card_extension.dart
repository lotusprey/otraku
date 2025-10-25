import 'package:flutter/material.dart';

extension CardExtension on Card {
  static final highContrast = (bool highContrast) => highContrast ? Card.outlined : Card.new;
}
