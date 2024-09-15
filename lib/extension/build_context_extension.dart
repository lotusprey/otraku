import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:otraku/util/routes.dart';

extension BuildContextExtension on BuildContext {
  void back() => canPop() ? pop() : go(Routes.home());
}
