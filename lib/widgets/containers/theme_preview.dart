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
  late int activeNow =
      widget.isDark ? Settings().darkTheme : Settings().lightTheme;

  late Iterable<MapEntry<String, ColorScheme>> themes = widget.isDark
      ? Theming.schemes.entries
          .where((entry) => entry.value.brightness == Brightness.dark)
      : Theming.schemes.entries
          .where((entry) => entry.value.brightness == Brightness.light);

  @override
  Widget build(BuildContext context) {
    final Map<String, int> colorSchemeMap = <String, int>{};
    for (int i = 0; i < Theming.schemes.length; i++)
      colorSchemeMap[Theming.schemes.keys.elementAt(i)] = i;

    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.only(bottom: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 5, left: 5),
              child: Text(
                widget.isDark ? "Dark Theme" : "Light Theme",
                style: Theme.of(context).textTheme.subtitle1,
              ),
            ),
            SizedBox(
              height: 200,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  for (var item in themes)
                    _ThemeCard(
                      key: Key(item.key),
                      name: item.key,
                      scheme: item.value,
                      active: activeNow == colorSchemeMap[item.key],
                      onTap: (name) {
                        setState(() => activeNow = colorSchemeMap[name]!);
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
    super.key,
    required this.name,
    required this.scheme,
    required this.active,
    required this.onTap,
  });

  final String name;
  final bool active;
  final ColorScheme scheme;
  final void Function(String name) onTap;

  @override
  Widget build(BuildContext context) {
    final double borderWidth = active ? 2 : 1;
    final Color borderColor = active ? scheme.primary : scheme.surfaceVariant;

    return GestureDetector(
      onTap: () => onTap(name),
      child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 5),
          child: Column(
            children: [
              Container(
                width: 120,
                height: 180,
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  color: scheme.background,
                  border: Border.all(color: borderColor, width: borderWidth),
                  borderRadius: Consts.borderRadiusMin,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(5),
                      child: Column(
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
                            decoration: BoxDecoration(
                              color: scheme.surface,
                              borderRadius: Consts.borderRadiusMin,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(5),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
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
                                  SizedBox(height: 5),
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
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 7.5, bottom: 5),
                          child: Container(
                            width: 16,
                            height: 16,
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
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
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
              Text(name)
            ],
          )),
    );
  }
}
