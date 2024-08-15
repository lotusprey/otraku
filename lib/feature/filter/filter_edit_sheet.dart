import 'package:flutter/material.dart';
import 'package:otraku/util/persistence.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/widget/layout/navigation_tool.dart';
import 'package:otraku/widget/sheets.dart';

class FilterEditSheet<T> extends StatelessWidget {
  const FilterEditSheet({
    required this.filter,
    required this.onCleared,
    required this.onChanged,
    required this.builder,
  });

  final T filter;
  final void Function() onCleared;
  final void Function(T) onChanged;
  final Widget Function(BuildContext, ScrollController, T) builder;

  @override
  Widget build(BuildContext context) {
    final applyButton = BottomBarButton(
      text: 'Apply',
      icon: Icons.done_rounded,
      onTap: () {
        onChanged(filter);
        Navigator.pop(context);
      },
    );

    final clearButton = BottomBarButton(
      text: 'Clear',
      icon: Icons.close,
      warning: true,
      onTap: () {
        onCleared();
        Navigator.pop(context);
      },
    );

    return SheetWithButtonRow(
      buttons: BottomBar(
        Persistence().leftHanded
            ? [applyButton, clearButton]
            : [clearButton, applyButton],
      ),
      builder: (context, scrollCtrl) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: Theming.offset),
        child: builder(context, scrollCtrl, filter),
      ),
    );
  }
}
