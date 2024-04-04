import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/common/utils/consts.dart';
import 'package:otraku/common/widgets/shadowed_overflow_list.dart';
import 'package:otraku/modules/home/home_provider.dart';
import 'package:otraku/common/utils/options.dart';
import 'package:otraku/common/utils/theming.dart';

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
              ? s.systemDarkScheme
              : s.systemLightScheme,
        ));

        final children = <_ThemeCard>[];
        if (system != null) {
          children.add(_ThemeCard(
            name: 'System',
            scheme: system,
            active: Options().theme == null,
            onTap: () => setState(() => Options().theme = null),
          ));
        }

        final background =
            brightness == Brightness.dark && Options().pureWhiteOrBlackTheme
                ? Colors.black
                : null;

        for (int i = 0; i < colorSeeds.length; i++) {
          final e = colorSeeds.entries.elementAt(i);
          children.add(_ThemeCard(
            name: e.key,
            scheme: e.value.scheme(brightness).copyWith(background: background),
            active: Options().theme == i,
            onTap: () => setState(() => Options().theme = i),
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
    final borderColor = active ? scheme.primary : scheme.surfaceVariant;

    return GestureDetector(
      onTap: onTap,
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
    );
  }
}
