import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/widget/dialogs.dart';
import 'package:otraku/widget/input/stateful_tiles.dart';
import 'package:otraku/widget/input/chip_selector.dart';
import 'package:otraku/feature/media/media_models.dart';
import 'package:otraku/feature/settings/settings_model.dart';
import 'package:otraku/widget/sheets.dart';

class SettingsContentSubview extends StatelessWidget {
  const SettingsContentSubview(this.scrollCtrl, this.settings);

  final ScrollController scrollCtrl;
  final Settings settings;

  @override
  Widget build(BuildContext context) {
    final listPadding = MediaQuery.paddingOf(context);
    const tilePadding = EdgeInsets.only(
      bottom: Theming.offset,
      left: Theming.offset,
      right: Theming.offset,
    );

    final sheetInitialHeight = MediaQuery.sizeOf(context).height;

    return ListView(
      controller: scrollCtrl,
      padding: .only(
        top: listPadding.top + Theming.offset,
        bottom: listPadding.bottom + Theming.offset,
      ),
      children: [
        ExpansionTile(
          title: const Text('Media'),
          initiallyExpanded: true,
          children: [
            Padding(
              padding: tilePadding,
              child: ChipSelector.ensureSelected(
                title: 'Title Language',
                items: TitleLanguage.values.map((v) => (v.label, v)).toList(),
                value: settings.titleLanguage,
                onChanged: (v) => settings.titleLanguage = v,
              ),
            ),
            Padding(
              padding: tilePadding,
              child: ChipSelector.ensureSelected(
                title: 'Character & Staff Names',
                items: PersonNaming.values.map((v) => (v.label, v)).toList(),
                value: settings.personNaming,
                onChanged: (v) => settings.personNaming = v,
              ),
            ),
            Padding(
              padding: tilePadding,
              child: ChipSelector.ensureSelected(
                title: 'Activity Merge Time',
                items: const [
                  ('Never', 0),
                  ('30 Minutes', 30),
                  ('1 Hour', 60),
                  ('2 Hours', 120),
                  ('3 Hours', 180),
                  ('6 Hours', 360),
                  ('12 Hours', 720),
                  ('1 Day', 1440),
                  ('2 Days', 2880),
                  ('3 Days', 4320),
                  ('1 Week', 10080),
                  ('2 Weeks', 20160),
                  ('Always', 29160),
                ],
                value: settings.activityMergeTime,
                onChanged: (v) => settings.activityMergeTime = v,
              ),
            ),
            StatefulSwitchListTile(
              title: const Text('18+ Content'),
              value: settings.displayAdultContent,
              onChanged: (val) => settings.displayAdultContent = val,
            ),
            StatefulSwitchListTile(
              title: const Text('Airing Anime Notifications'),
              value: settings.airingNotifications,
              onChanged: (val) => settings.airingNotifications = val,
            ),
          ],
        ),
        ExpansionTile(
          title: const Text('Lists'),
          initiallyExpanded: true,
          children: [
            Padding(
              padding: tilePadding,
              child: ChipSelector.ensureSelected(
                title: 'Scoring System',
                items: ScoreFormat.values.map((v) => (v.label, v)).toList(),
                value: settings.scoreFormat,
                onChanged: (v) => settings.scoreFormat = v,
              ),
            ),
            Padding(
              padding: tilePadding,
              child: ChipSelector.ensureSelected(
                title: 'Default Site List Sort',
                items: EntrySort.rowOrders.map((v) => (v.label, v)).toList(),
                value: settings.defaultSort,
                onChanged: (v) => settings.defaultSort = v,
              ),
            ),
            StatefulCheckboxListTile(
              title: const Text('Split Completed Anime'),
              value: settings.splitCompletedAnime,
              onChanged: (val) => settings.splitCompletedAnime = val!,
            ),
            ListTile(
              title: const Text('Anime Custom Lists'),
              leading: const Icon(Ionicons.film_outline),
              onTap: () => showSheet(
                context,
                SimpleSheet(
                  initialHeight: sheetInitialHeight,
                  builder: (context, scrollCtrl) => _ListManagement(
                    title: 'Anime Custom Lists',
                    label: 'Anime custom list',
                    items: settings.animeCustomLists,
                    scrollCtrl: scrollCtrl,
                  ),
                ),
              ),
            ),
            StatefulCheckboxListTile(
              title: const Text('Split Completed Manga'),
              value: settings.splitCompletedManga,
              onChanged: (val) => settings.splitCompletedManga = val!,
            ),
            ListTile(
              title: const Text('Manga Custom Lists'),
              leading: const Icon(Ionicons.book_outline),
              onTap: () => showSheet(
                context,
                SimpleSheet(
                  initialHeight: sheetInitialHeight,
                  builder: (context, scrollCtrl) => _ListManagement(
                    title: 'Manga Custom Lists',
                    label: 'Manga custom list',
                    items: settings.mangaCustomLists,
                    scrollCtrl: scrollCtrl,
                  ),
                ),
              ),
            ),
            StatefulSwitchListTile(
              title: const Text('Advanced Scoring'),
              value: settings.advancedScoringEnabled,
              onChanged: (val) => settings.advancedScoringEnabled = val,
            ),
            ListTile(
              title: const Text('Advanced Score Sections'),
              leading: const Icon(Ionicons.star_half),
              onTap: () => showSheet(
                context,
                SimpleSheet(
                  initialHeight: sheetInitialHeight,
                  builder: (context, scrollCtrl) => _ListManagement(
                    title: 'Advanced Score Sections',
                    label: 'Advanced score section',
                    items: settings.advancedScoreSections,
                    scrollCtrl: scrollCtrl,
                  ),
                ),
              ),
            ),
          ],
        ),
        ExpansionTile(
          title: const Text('Social'),
          initiallyExpanded: true,
          expandedCrossAxisAlignment: .stretch,
          children: [
            for (final e in settings.disabledListActivity.entries)
              StatefulCheckboxListTile(
                title: Text('Create ${e.key.label(null)} Activities'),
                value: !e.value,
                onChanged: (val) => settings.disabledListActivity[e.key] = !val!,
              ),
            StatefulSwitchListTile(
              title: const Text('Limit Messages'),
              subtitle: const Text('Only users I follow can message me'),
              value: settings.restrictMessagesToFollowing,
              onChanged: (val) => settings.restrictMessagesToFollowing = val,
            ),
          ],
        ),
      ],
    );
  }
}

class _ListManagement extends StatefulWidget {
  const _ListManagement({
    required this.title,
    required this.label,
    required this.items,
    required this.scrollCtrl,
  });

  final String title;
  final String label;
  final List<String> items;
  final ScrollController scrollCtrl;

  @override
  State<_ListManagement> createState() => _ListManagementState();
}

class _ListManagementState extends State<_ListManagement> {
  @override
  Widget build(BuildContext context) {
    final items = widget.items;

    return Column(
      mainAxisSize: .min,
      crossAxisAlignment: .stretch,
      children: [
        Padding(
          padding: const .only(top: Theming.offset),
          child: Row(
            children: [
              Padding(
                padding: const .symmetric(horizontal: Theming.offset),
                child: Text(widget.title, style: TextTheme.of(context).titleLarge),
              ),
              const Spacer(),
              IconButton(
                tooltip: 'Add',
                icon: const Icon(Icons.add_rounded),
                onPressed: () async {
                  final newItem = await showDialog<String?>(
                    context: context,
                    builder: (context) => TextInputDialog(
                      title: widget.label,
                      initialValue: '',
                      validator: (val) => items.contains(val) ? 'Already exists.' : null,
                    ),
                  );

                  if (newItem != null) {
                    setState(() => items.add(newItem));
                  }
                },
              ),
            ],
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          controller: widget.scrollCtrl,
          itemCount: items.length,
          itemBuilder: (context, i) => ListTile(
            key: Key(items[i]),
            title: Text(items[i]),
            trailing: Row(
              mainAxisSize: .min,
              children: [
                IconButton(
                  tooltip: 'Remove',
                  icon: const Icon(Icons.delete_rounded),
                  onPressed: () => setState(() => items.removeAt(i)),
                ),
                IconButton(
                  tooltip: 'Rename',
                  icon: const Icon(Icons.edit_rounded),
                  onPressed: () async {
                    final renamedItem = await showDialog<String?>(
                      context: context,
                      builder: (context) => TextInputDialog(
                        title: widget.label,
                        initialValue: items[i],
                        validator: (val) =>
                            items.contains(val) && val != items[i] ? 'Already exists.' : null,
                      ),
                    );

                    if (renamedItem != null) {
                      setState(() => items[i] = renamedItem);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
