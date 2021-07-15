import 'package:flutter/material.dart';

class RoutePage extends MaterialPage {
  RoutePage({
    required this.tag,
    required String name,
    required Widget child,
    required List<dynamic> args,
  }) : super(name: name, child: child, arguments: args);

  // This property shouldn't be null if there is a controller with
  // a tag, unknown at compile time, associated with the page.
  final String? tag;
}
