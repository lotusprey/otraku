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

    final update = (Options options) =>
        ref.read(persistenceProvider.notifier).setOptions(options);

    return ListView(
      controller: scrollCtrl,
      padding: EdgeInsets.only(
        top: listPadding.top + Theming.offset,
        bottom: listPadding.bottom + Theming.offset + 60,
      ),
      children: [
        ExpansionTile(
          title: const Text('Appearance'),
          initiallyExpanded: true,
          expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ThemeModeSelection(
              value: options.themeMode,
              onChanged: (themeMode) => update(
                options.copyWith(themeMode: themeMode),
              ),
            ),
            ThemePreview(ref: ref, options: options),
            StatefulSwitchListTile(
              title: const Text('High Contrast'),
              subtitle: const Text('Pure white/black backgrounds'),
              value: options.highContrast,
              onChanged: (v) => update(options.copyWith(highContrast: v)),
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
              onChanged: (v) => update(
                options.copyWith(animeCollectionPreview: v),
              ),
            ),
            StatefulSwitchListTile(
              title: const Text('Manga Collection Preview'),
              subtitle: const Text(
                'Only load your read/reread manga '
                'and expand to full collection with the floating button',
              ),
              value: options.mangaCollectionPreview,
              onChanged: (v) => update(
                options.copyWith(mangaCollectionPreview: v),
              ),
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
              ),
            ),
            Padding(
              padding: tilePadding,
              child: ChipSelector.ensureSelected(
                title: 'Discover Type',
                items: DiscoverType.values.map((v) => (v.label, v)).toList(),
                value: options.discoverType,
                onChanged: (v) => update(
                  options.copyWith(discoverType: v),
                ),
              ),
            ),
            Padding(
              padding: tilePadding,
              child: ChipSelector.ensureSelected(
                title: 'Image Quality',
                items: ImageQuality.values.map((v) => (v.label, v)).toList(),
                value: options.imageQuality,
                onChanged: (v) => update(options.copyWith(imageQuality: v)),
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
                onChanged: (v) => update(
                  options.copyWith(collectionItemView: v),
                ),
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
                onChanged: (v) => update(
                  options.copyWith(collectionPreviewItemView: v),
                ),
              ),
            ),
          ],
        ),
        StatefulSwitchListTile(
          title: const Text('Left-Handed Mode'),
          value: options.leftHanded,
          onChanged: (v) => update(options.copyWith(leftHanded: v)),
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

class _ThemeModeSelection extends StatelessWidget {
  const _ThemeModeSelection({required this.value, required this.onChanged});

  final ThemeMode value;
  final void Function(ThemeMode) onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: Theming.offset,
        left: Theming.offset,
        right: Theming.offset,
      ),
      child: SegmentedButton(
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
        selected: {value},
        onSelectionChanged: (v) => onChanged(v.first),
      ),
    );
  }
}
