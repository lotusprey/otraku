import 'package:flutter/material.dart';
import 'package:otraku/constants/consts.dart';
import 'package:otraku/utils/theming.dart';
import 'package:otraku/utils/settings.dart';

class ThemePreview extends StatefulWidget {
  const ThemePreview({required this.isDark});

  final bool isDark;

  @override
  State<StatefulWidget> createState() => _ThemePreviewState();
}

class _ThemePreviewState extends State<ThemePreview> {
  late int index = widget.isDark ? Settings().darkTheme : Settings().lightTheme;

  late final themes = widget.isDark
      ? Theming.schemes.entries
          .where((entry) => entry.value.brightness == Brightness.dark)
      : Theming.schemes.entries
          .where((entry) => entry.value.brightness == Brightness.light);

  @override
  Widget build(BuildContext context) {
    final colorSchemeMap = <String, int>{};
    for (int i = 0; i < Theming.schemes.length; i++) {
      colorSchemeMap[Theming.schemes.keys.elementAt(i)] = i;
    }

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10, bottom: 5),
              child: Text(
                widget.isDark ? "Dark Theme" : "Light Theme",
                style: Theme.of(context).textTheme.subtitle1,
              ),
            ),
            SizedBox(
              height: 200,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 5),
                children: [
                  for (final item in themes)
                    _ThemeCard(
                      name: item.key,
                      scheme: item.value,
                      active: index == colorSchemeMap[item.key],
                      onTap: (name) {
                        setState(() => index = colorSchemeMap[name]!);
                        widget.isDark
                            ? Settings().darkTheme = colorSchemeMap[name]!
                            : Settings().lightTheme = colorSchemeMap[name]!;
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeCard extends StatelessWidget {
  const _ThemeCard({
    required this.name,
    required this.scheme,
    required this.active,
    required this.onTap,
  });

  final String name;
  final bool active;
  final ColorScheme scheme;
  final void Function(String) onTap;

  @override
  Widget build(BuildContext context) {
    final borderWidth = active ? 3.0 : 1.0;
    final borderColor = active ? scheme.primary : scheme.surfaceVariant;

    return GestureDetector(
      onTap: () => onTap(name),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Column(
          children: [
            Container(
              width: 120,
              height: 180,
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: scheme.background,
                border: Border.all(color: borderColor, width: borderWidth),
                borderRadius: Consts.borderRadiusMin,
              ),
              child: Column(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 10,
                        width: 60,
                        decoration: BoxDecoration(
                          color: scheme.onBackground,
                          borderRadius: Consts.borderRadiusMax,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        height: 40,
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: scheme.surface,
                          borderRadius: Consts.borderRadiusMin,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 8,
                              width: 40,
                              decoration: BoxDecoration(
                                color: scheme.surfaceVariant,
                                borderRadius: Consts.borderRadiusMax,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Container(
                              height: 6,
                              width: 110,
                              decoration: BoxDecoration(
                                color: scheme.onSurface,
                                borderRadius: Consts.borderRadiusMax,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        margin: const EdgeInsets.only(right: 7, bottom: 7),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: scheme.primary,
                        ),
                        child: Center(
                          child: Container(
                            width: 6,
                            height: 2,
                            decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              borderRadius: Consts.borderRadiusMin,
                              color: scheme.onPrimary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 15,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          height: 8,
                          width: 8,
                          decoration: BoxDecoration(
                            color: scheme.primary,
                            shape: BoxShape.rectangle,
                          ),
                        ),
                        Container(
                          height: 8,
                          width: 8,
                          decoration: BoxDecoration(
                            color: scheme.surfaceVariant,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Container(
                          height: 8,
                          width: 8,
                          decoration: BoxDecoration(
                            color: scheme.surfaceVariant,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            const Spacer(),
            Text(name),
          ],
        ),
      ),
    );
  }
}
