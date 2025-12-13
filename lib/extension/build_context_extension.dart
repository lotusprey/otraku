import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:otraku/util/routes.dart';
import 'package:otraku/util/theming.dart';

extension BuildContextExtension on BuildContext {
  void back() => canPop() ? pop() : go(Routes.home());

  double lineHeight(TextStyle style) {
    final scaler = MediaQuery.textScalerOf(this);
    final scaled = scaler.scale(style.fontSize ?? Theming.fontMedium) * (style.height ?? 1);
    return scaled.ceilToDouble();
  }
}
