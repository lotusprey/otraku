import 'package:flutter/material.dart';
import 'package:otraku/constants/consts.dart';
import 'package:otraku/utils/settings.dart';
import 'package:otraku/widgets/fields/checkbox_field.dart';

class OpaqueSheet extends StatelessWidget {
  OpaqueSheet({required this.builder, this.height = 0.5});

  final Widget Function(BuildContext, ScrollController) builder;
  final double height;

  @override
  Widget build(BuildContext context) {
    Widget? sheet;

    return DraggableScrollableSheet(
      expand: false,
      maxChildSize: 0.9,
      initialChildSize: height,
      minChildSize: height < 0.25 ? height : 0.25,
      builder: (context, scrollCtrl) {
        if (sheet == null)
          sheet = Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: Consts.OVERLAY_TIGHT),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.background,
                borderRadius:
                    const BorderRadius.vertical(top: Consts.RADIUS_MAX),
              ),
              child: builder(context, scrollCtrl),
            ),
          );

        return sheet!;
      },
    );
  }
}

class SelectionOpaqueSheet<T> extends StatelessWidget {
  SelectionOpaqueSheet({
    required this.options,
    required this.values,
    required this.selected,
  });

  final List<String> options;
  final List<T> values;
  final List<T> selected;

  @override
  Widget build(BuildContext context) {
    final requiredHeight =
        options.length * Consts.MATERIAL_TAP_TARGET_SIZE + 20;
    double height = requiredHeight / MediaQuery.of(context).size.height;
    if (height > 0.9) height = 0.9;

    return OpaqueSheet(
      height: height,
      builder: (context, scrollCtrl) => ListView.builder(
        controller: scrollCtrl,
        physics: Consts.PHYSICS,
        padding: Consts.PADDING,
        itemCount: options.length,
        itemExtent: Consts.MATERIAL_TAP_TARGET_SIZE,
        itemBuilder: (_, index) => CheckBoxField(
          title: options[index],
          initial: selected.contains(values[index]),
          onChanged: (val) => val
              ? selected.add(values[index])
              : selected.remove(values[index]),
        ),
      ),
    );
  }
}

class OpaqueSheetView extends StatelessWidget {
  OpaqueSheetView({required this.builder, required this.buttons});

  final Widget Function(BuildContext, ScrollController) builder;
  final List<Widget> buttons;

  @override
  Widget build(BuildContext context) {
    Widget? sheet;

    return DraggableScrollableSheet(
      expand: false,
      maxChildSize: 0.9,
      initialChildSize: 0.7,
      builder: (context, scrollCtrl) {
        if (sheet == null)
          sheet = Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: Consts.OVERLAY_WIDE),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.background,
                borderRadius:
                    const BorderRadius.vertical(top: Consts.RADIUS_MAX),
              ),
              child: Stack(
                children: [
                  builder(context, scrollCtrl),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: ClipRect(
                      child: BackdropFilter(
                        filter: Consts.filter,
                        child: Container(
                          height:
                              MediaQuery.of(context).viewPadding.bottom + 50,
                          padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewPadding.bottom,
                          ),
                          color: Theme.of(context).cardColor,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: Settings().leftHanded
                                ? buttons.reversed.toList()
                                : buttons,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );

        return sheet!;
      },
    );
  }
}

class OpaqueSheetViewButton extends StatelessWidget {
  OpaqueSheetViewButton({
    required this.text,
    required this.icon,
    required this.onTap,
    this.warning = false,
  });

  final String text;
  final IconData icon;
  final void Function() onTap;
  final bool warning;

  @override
  Widget build(BuildContext context) {
    ButtonStyle style = Theme.of(context).textButtonTheme.style!;
    if (warning)
      style = style.copyWith(
        foregroundColor: MaterialStateProperty.all(
          Theme.of(context).colorScheme.error,
        ),
      );

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: TextButton.icon(
          label: Text(text),
          icon: Icon(icon),
          onPressed: onTap,
          style: style,
        ),
      ),
    );
  }
}
