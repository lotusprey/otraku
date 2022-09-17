import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/constants/consts.dart';
import 'package:otraku/home/home_provider.dart';
import 'package:otraku/utils/settings.dart';
import 'package:otraku/utils/theming.dart';

class ThemePreview extends StatefulWidget {
  const ThemePreview();

  @override
  State<StatefulWidget> createState() => _ThemePreviewState();
}

class _ThemePreviewState extends State<ThemePreview> {
  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).colorScheme.brightness;

    return Consumer(
      builder: (context, ref, _) {
        final system = ref
            .watch(homeProvider)
            .getSystemScheme(brightness == Brightness.dark);

        final children = <_ThemeCard>[];
        if (system != null) {
          children.add(_ThemeCard(
            name: 'System',
            scheme: system,
            active: Settings().theme == null,
            onTap: () => setState(() => Settings().theme = null),
          ));
        }

        final background =
            brightness == Brightness.dark && Settings().pureBlackDarkTheme
                ? Colors.black
                : null;

        for (int i = 0; i < colorSeeds.length; i++) {
          final e = colorSeeds.entries.elementAt(i);
          children.add(_ThemeCard(
            name: e.key,
            scheme: e.value.scheme(brightness).copyWith(background: background),
            active: Settings().theme == i,
            onTap: () => setState(() => Settings().theme = i),
          ));
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
                    "Theme",
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                ),
                SizedBox(
                  height: 190,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    children: children,
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    final borderWidth = active ? 3.0 : 1.0;
    final borderColor = active ? scheme.primary : scheme.surfaceVariant;

    return GestureDetector(
      onTap: () => onTap(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Column(
          children: [
            Container(
              width: 120,
              height: 170,
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
                          color: scheme.surfaceVariant,
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
                                color: scheme.onSurfaceVariant,
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
