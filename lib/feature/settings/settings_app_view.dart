import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/feature/collection/collection_models.dart';
import 'package:otraku/feature/viewer/persistence_model.dart';
import 'package:otraku/feature/viewer/persistence_provider.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/widget/input/stateful_tiles.dart';
import 'package:otraku/feature/discover/discover_model.dart';
import 'package:otraku/widget/input/chip_selector.dart';
import 'package:otraku/feature/home/home_model.dart';
import 'package:otraku/feature/settings/theme_preview.dart';

class SettingsAppSubview extends ConsumerWidget {
  const SettingsAppSubview(this.scrollCtrl);

  final ScrollController scrollCtrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listPadding = MediaQuery.paddingOf(context);
    const tilePadding = EdgeInsets.only(
      bottom: Theming.offset,
      left: Theming.offset,
      right: Theming.offset,
    );

    final options = ref.watch(persistenceProvider.select((s) => s.options));

    final update = (Options options) => ref.read(persistenceProvider.notifier).setOptions(options);

    return ListView(
      controller: scrollCtrl,
      padding: .only(
        top: listPadding.top + Theming.offset,
        bottom: listPadding.bottom + Theming.offset + 60,
      ),
      children: [
        ExpansionTile(
          title: const Text('Appearance'),
          initiallyExpanded: true,
          expandedCrossAxisAlignment: .stretch,
          children: [
            Padding(
              padding: const .only(
                bottom: Theming.offset,
                left: Theming.offset,
                right: Theming.offset,
              ),
              child: StatefulSegmentedButton(
                segments: const [
                  ButtonSegment(
                    value: ThemeMode.system,
                    label: Text('System'),
                    icon: Icon(Icons.sync_outlined),
                  ),
                  ButtonSegment(
                    value: ThemeMode.light,
                    label: Text('Light'),
                    icon: Icon(Icons.wb_sunny_outlined),
                  ),
                  ButtonSegment(
                    value: ThemeMode.dark,
                    label: Text('Dark'),
                    icon: Icon(Icons.mode_night_outlined),
                  ),
                ],
                value: options.themeMode,
                onChanged: (themeMode) => update(options.copyWith(themeMode: themeMode)),
              ),
            ),
            ThemePreview(ref: ref, options: options),
            const SizedBox(height: Theming.offset / 2),
            StatefulSwitchListTile(
              title: const Text('High Contrast'),
              subtitle: const Text('Pure backgrounds & outlined cards'),
              value: options.highContrast,
              onChanged: (v) => update(options.copyWith(highContrast: v)),
            ),
            const SizedBox(height: Theming.offset / 2),
            Padding(
              padding: const .only(
                left: Theming.offset,
                right: Theming.offset,
                bottom: Theming.offset,
              ),
              child: const Text('Button Orientation'),
            ),
            Padding(
              padding: const .only(
                left: Theming.offset,
                right: Theming.offset,
                bottom: Theming.offset,
              ),
              child: StatefulSegmentedButton(
                segments: const [
                  ButtonSegment(
                    value: ButtonOrientation.auto,
                    label: Text('Auto'),
                    icon: Icon(Icons.align_horizontal_center_rounded),
                  ),
                  ButtonSegment(
                    value: ButtonOrientation.left,
                    label: Text('Left'),
                    icon: Icon(Icons.align_horizontal_left_rounded),
                  ),
                  ButtonSegment(
                    value: ButtonOrientation.right,
                    label: Text('Right'),
                    icon: Icon(Icons.align_horizontal_right_rounded),
                  ),
                ],
                value: options.buttonOrientation,
                onChanged: (buttonOrientation) =>
                    update(options.copyWith(buttonOrientation: buttonOrientation)),
              ),
            ),
          ],
        ),
        ExpansionTile(
          title: const Text('Collection Previews'),
          children: [
            StatefulSwitchListTile(
              title: const Text('Anime Collection Preview'),
              subtitle: const Text(
                'Only load your watched/rewatched anime '
                'and expand to full collection with the floating button',
              ),
              value: options.animeCollectionPreview,
              onChanged: (v) => update(options.copyWith(animeCollectionPreview: v)),
            ),
            StatefulSwitchListTile(
              title: const Text('Manga Collection Preview'),
              subtitle: const Text(
                'Only load your read/reread manga '
                'and expand to full collection with the floating button',
              ),
              value: options.mangaCollectionPreview,
              onChanged: (v) => update(options.copyWith(mangaCollectionPreview: v)),
            ),
          ],
        ),
        ExpansionTile(
          title: const Text('Defaults'),
          children: [
            Padding(
              padding: tilePadding,
              child: ChipSelector.ensureSelected(
                title: 'Home Tab',
                items: HomeTab.values.map((v) => (v.label, v)).toList(),
                value: options.homeTab,
                onChanged: (v) => update(options.copyWith(homeTab: v)),
                highContrast: options.highContrast,
              ),
            ),
            Padding(
              padding: tilePadding,
              child: ChipSelector.ensureSelected(
                title: 'Discover Type',
                items: DiscoverType.values.map((v) => (v.label, v)).toList(),
                value: options.discoverType,
                onChanged: (v) => update(options.copyWith(discoverType: v)),
                highContrast: options.highContrast,
              ),
            ),
            Padding(
              padding: tilePadding,
              child: ChipSelector.ensureSelected(
                title: 'Image Quality',
                items: ImageQuality.values.map((v) => (v.label, v)).toList(),
                value: options.imageQuality,
                onChanged: (v) => update(options.copyWith(imageQuality: v)),
                highContrast: options.highContrast,
              ),
            ),
          ],
        ),
        ExpansionTile(
          title: const Text('View Layouts'),
          children: [
            Padding(
              padding: tilePadding,
              child: ChipSelector.ensureSelected(
                title: 'Discover View',
                items: const [
                  ('Detailed', DiscoverItemView.detailed),
                  ('Simple', DiscoverItemView.simple),
                ],
                value: options.discoverItemView,
                onChanged: (v) => update(options.copyWith(discoverItemView: v)),
                highContrast: options.highContrast,
              ),
            ),
            Padding(
              padding: tilePadding,
              child: ChipSelector.ensureSelected(
                title: 'Collection View',
                items: const [
                  ('Detailed', CollectionItemView.detailed),
                  ('Simple', CollectionItemView.simple),
                ],
                value: options.collectionItemView,
                onChanged: (v) => update(options.copyWith(collectionItemView: v)),
                highContrast: options.highContrast,
              ),
            ),
            Padding(
              padding: tilePadding,
              child: ChipSelector.ensureSelected(
                title: 'Collection Preview View',
                items: const [
                  ('Detailed', CollectionItemView.detailed),
                  ('Simple', CollectionItemView.simple),
                ],
                value: options.collectionPreviewItemView,
                onChanged: (v) => update(options.copyWith(collectionPreviewItemView: v)),
                highContrast: options.highContrast,
              ),
            ),
          ],
        ),
        StatefulSwitchListTile(
          title: const Text('12 Hour Clock'),
          value: options.analogClock,
          onChanged: (v) => update(options.copyWith(analogClock: v)),
        ),
        StatefulSwitchListTile(
          title: const Text('Confirm Exit'),
          value: options.confirmExit,
          onChanged: (v) => update(options.copyWith(confirmExit: v)),
        ),
      ],
    );
  }
}
