import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/settings/visual_preview_card.dart';
import 'package:otraku/utils/consts.dart';
import 'package:otraku/home/home_provider.dart';
import 'package:otraku/utils/options.dart';
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

        final children = <VisualPreviewCard>[];
        if (system != null) {
          children.add(VisualPreviewCard(
            name: 'System',
            scheme: system,
            active: Options().theme == null,
            onTap: () => setState(() => Options().theme = null),
            child: _ThemeCardContent(system),
          ));
        }

        final background =
            brightness == Brightness.dark && Options().pureBlackDarkTheme
                ? Colors.black
                : null;

        for (int i = 0; i < colorSeeds.length; i++) {
          final e = colorSeeds.entries.elementAt(i);
          final scheme =
              e.value.scheme(brightness).copyWith(background: background);

          children.add(VisualPreviewCard(
            name: e.key,
            scheme: scheme,
            active: Options().theme == i,
            onTap: () => setState(() => Options().theme = i),
            child: _ThemeCardContent(scheme),
          ));
        }

        return SliverToBoxAdapter(
          child: SizedBox(
            height: 190,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 5),
              children: children,
            ),
          ),
        );
      },
    );
  }
}

class _ThemeCardContent extends StatelessWidget {
  const _ThemeCardContent(this.scheme);

  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Column(
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
    );
  }
}
