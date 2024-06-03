import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/widget/shadowed_overflow_list.dart';
import 'package:otraku/feature/home/home_provider.dart';
import 'package:otraku/util/persistence.dart';
import 'package:otraku/util/theming.dart';

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
        final system = ref.watch(homeProvider.select(
          (s) => brightness == Brightness.dark
              ? s.systemDarkPrimaryColor
              : s.systemLightPrimaryColor,
        ));

        final background =
            brightness == Brightness.dark && Persistence().pureWhiteOrBlackTheme
                ? Colors.black
                : null;

        final children = <_ThemeCard>[];
        if (system != null) {
          children.add(_ThemeCard(
            name: 'System',
            scheme: ColorScheme.fromSeed(
              seedColor: system,
              brightness: brightness,
            ).copyWith(surface: background),
            active: Persistence().theme == null,
            onTap: () => setState(() => Persistence().theme = null),
          ));
        }

        for (int i = 0; i < Theming.colorSeeds.length; i++) {
          final e = Theming.colorSeeds.entries.elementAt(i);
          children.add(_ThemeCard(
            name: e.key,
            scheme: ColorScheme.fromSeed(
              seedColor: e.value,
              brightness: brightness,
            ).copyWith(surface: background),
            active: Persistence().theme == i,
            onTap: () => setState(() => Persistence().theme = i),
          ));
        }

        return SizedBox(
          height: 195,
          child: ShadowedOverflowList(
            itemCount: children.length,
            itemBuilder: (_, i) => children[i],
          ),
        );
      },
    );
  }
}

class _ThemeCard extends StatelessWidget {
  const _ThemeCard({
    required this.name,
    required this.active,
    required this.scheme,
    required this.onTap,
  });

  final String name;
  final bool active;
  final ColorScheme scheme;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    final borderWidth = active ? 3.0 : 1.0;
    final borderColor =
        active ? scheme.primary : scheme.surfaceContainerHighest;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 120,
            height: 170,
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: scheme.surface,
              border: Border.all(color: borderColor, width: borderWidth),
              borderRadius: Theming.borderRadiusSmall,
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
                        color: scheme.onSurface,
                        borderRadius: Theming.borderRadiusBig,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 40,
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerHighest,
                        borderRadius: Theming.borderRadiusSmall,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 8,
                            width: 40,
                            decoration: BoxDecoration(
                              color: scheme.surfaceContainerHighest,
                              borderRadius: Theming.borderRadiusBig,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Container(
                            height: 6,
                            width: 110,
                            decoration: BoxDecoration(
                              color: scheme.onSurfaceVariant,
                              borderRadius: Theming.borderRadiusBig,
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
                            borderRadius: Theming.borderRadiusSmall,
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
                          color: scheme.surfaceContainerHighest,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Container(
                        height: 8,
                        width: 8,
                        decoration: BoxDecoration(
                          color: scheme.surfaceContainerHighest,
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
    );
  }
}
