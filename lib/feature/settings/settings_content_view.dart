import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/localizations/gen.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/widget/dialogs.dart';
import 'package:otraku/widget/input/stateful_tiles.dart';
import 'package:otraku/widget/input/chip_selector.dart';
import 'package:otraku/feature/media/media_models.dart';
import 'package:otraku/feature/settings/settings_model.dart';
import 'package:otraku/widget/sheets.dart';

class SettingsContentSubview extends StatelessWidget {
  const SettingsContentSubview(this.scrollCtrl, this.settings, this.highContrast);

  final ScrollController scrollCtrl;
  final Settings settings;
  final bool highContrast;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
          title: Text(l10n.media),
          initiallyExpanded: true,
          children: [
            Padding(
              padding: tilePadding,
              child: ChipSelector.ensureSelected(
                title: l10n.settingsMediaTitleLanguage,
                items: TitleLanguage.values.map((v) => (v.localize(l10n), v)).toList(),
                value: settings.titleLanguage,
                onChanged: (v) => settings.titleLanguage = v,
                highContrast: highContrast,
              ),
            ),
            Padding(
              padding: tilePadding,
              child: ChipSelector.ensureSelected(
                title: l10n.settingsMediaPersonNaming,
                items: PersonNaming.values.map((v) => (v.localize(l10n), v)).toList(),
                value: settings.personNaming,
                onChanged: (v) => settings.personNaming = v,
                highContrast: highContrast,
              ),
            ),
            Padding(
              padding: tilePadding,
              child: ChipSelector.ensureSelected(
                title: l10n.settingsMediaActivityMergeTime,
                items:
                    (const [0, 30, 60, 120, 180, 360, 720, 1440, 2880, 4320, 10080, 20160, 29160])
                        .map(
                          (mins) => (
                            switch (mins) {
                              0 => l10n.settingsMediaActivityMergeTimeNever,
                              < 60 => l10n.settingsMediaActivityMergeTimeMinutes(mins),
                              < 1440 => l10n.settingsMediaActivityMergeTimeHours(mins ~/ 60),
                              < 10080 => l10n.settingsMediaActivityMergeTimeHours(mins ~/ 1440),
                              < 29160 => l10n.settingsMediaActivityMergeTimeWeeks(mins ~/ 10080),
                              _ => l10n.settingsMediaActivityMergeTimeAlways,
                            },
                            mins,
                          ),
                        )
                        .toList(),
                value: settings.activityMergeTime,
                onChanged: (v) => settings.activityMergeTime = v,
                highContrast: highContrast,
              ),
            ),
            StatefulSwitchListTile(
              title: Text(l10n.settingsMediaAdult),
              value: settings.displayAdultContent,
              onChanged: (val) => settings.displayAdultContent = val,
            ),
            StatefulSwitchListTile(
              title: Text(l10n.settingsMediaAiringAnimeNotifications),
              value: settings.airingNotifications,
              onChanged: (val) => settings.airingNotifications = val,
            ),
          ],
        ),
        ExpansionTile(
          title: Text(l10n.list),
          initiallyExpanded: true,
          children: [
            Padding(
              padding: tilePadding,
              child: ChipSelector.ensureSelected(
                title: l10n.settingsListsScoringSystem,
                items: ScoreFormat.values.map((v) => (v.localize(l10n), v)).toList(),
                value: settings.scoreFormat,
                onChanged: (v) => settings.scoreFormat = v,
                highContrast: highContrast,
              ),
            ),
            Padding(
              padding: tilePadding,
              child: ChipSelector.ensureSelected(
                title: l10n.settingsListsDefaultSiteSort,
                items: EntrySort.rowOrders.map((v) => (v.localize(l10n), v)).toList(),
                value: settings.defaultSort,
                onChanged: (v) => settings.defaultSort = v,
                highContrast: highContrast,
              ),
            ),
            StatefulCheckboxListTile(
              title: Text(l10n.settingsListsSplitAnime),
              value: settings.splitCompletedAnime,
              onChanged: (val) => settings.splitCompletedAnime = val!,
            ),
            ListTile(
              title: Text(l10n.settingsListsCustomListsAnime(settings.animeCustomLists.length)),
              leading: const Icon(Ionicons.film_outline),
              onTap: () => showSheet(
                context,
                SimpleSheet(
                  initialHeight: sheetInitialHeight,
                  builder: (context, scrollCtrl) => _ListManagement(
                    title: l10n.settingsListsCustomListsAnime(settings.animeCustomLists.length),
                    label: l10n.settingsListsCustomListsAnime(1),
                    items: settings.animeCustomLists,
                    scrollCtrl: scrollCtrl,
                  ),
                ),
              ),
            ),
            StatefulCheckboxListTile(
              title: Text(l10n.settingsListsSplitManga),
              value: settings.splitCompletedManga,
              onChanged: (val) => settings.splitCompletedManga = val!,
            ),
            ListTile(
              title: Text(l10n.settingsListsCustomListsManga(settings.mangaCustomLists.length)),
              leading: const Icon(Ionicons.book_outline),
              onTap: () => showSheet(
                context,
                SimpleSheet(
                  initialHeight: sheetInitialHeight,
                  builder: (context, scrollCtrl) => _ListManagement(
                    title: l10n.settingsListsCustomListsManga(settings.mangaCustomLists.length),
                    label: l10n.settingsListsCustomListsManga(1),
                    items: settings.mangaCustomLists,
                    scrollCtrl: scrollCtrl,
                  ),
                ),
              ),
            ),
            StatefulSwitchListTile(
              title: Text(l10n.settingsListsScoringAdvanced),
              value: settings.advancedScoringEnabled,
              onChanged: (val) => settings.advancedScoringEnabled = val,
            ),
            ListTile(
              title: Text(
                l10n.settingsListsScoringAdvancedSections(settings.advancedScoreSections.length),
              ),
              leading: const Icon(Ionicons.star_half),
              onTap: () => showSheet(
                context,
                SimpleSheet(
                  initialHeight: sheetInitialHeight,
                  builder: (context, scrollCtrl) => _ListManagement(
                    title: l10n.settingsListsScoringAdvancedSections(
                      settings.advancedScoreSections.length,
                    ),
                    label: l10n.settingsListsScoringAdvancedSections(1),
                    items: settings.advancedScoreSections,
                    scrollCtrl: scrollCtrl,
                  ),
                ),
              ),
            ),
          ],
        ),
        ExpansionTile(
          title: Text(l10n.social),
          initiallyExpanded: true,
          expandedCrossAxisAlignment: .stretch,
          children: [
            for (final e in settings.disabledListActivity.entries)
              StatefulCheckboxListTile(
                title: Text(l10n.settingsSocialActivityCreation(e.key.localize(l10n, null))),
                value: !e.value,
                onChanged: (val) => settings.disabledListActivity[e.key] = !val!,
              ),
            StatefulSwitchListTile(
              title: Text(l10n.settingsSocialLimitMessages),
              subtitle: Text(l10n.settingsSocialLimitMessagesDescription),
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
    final l10n = AppLocalizations.of(context)!;
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
                child: Text(widget.title, style: TextTheme.of(context).bodyMedium),
              ),
              const Spacer(),
              IconButton(
                tooltip: l10n.actionAdd,
                icon: const Icon(Icons.add_rounded),
                onPressed: () async {
                  final newItem = await showDialog<String?>(
                    context: context,
                    builder: (context) => TextInputDialog(
                      title: widget.label,
                      initialValue: '',
                      validator: (val) => items.contains(val) ? l10n.errorAlreadyExists : null,
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
                  tooltip: l10n.actionRemove,
                  icon: const Icon(Icons.delete_rounded),
                  onPressed: () => setState(() => items.removeAt(i)),
                ),
                IconButton(
                  tooltip: l10n.actionRename,
                  icon: const Icon(Icons.edit_rounded),
                  onPressed: () async {
                    final renamedItem = await showDialog<String?>(
                      context: context,
                      builder: (context) => TextInputDialog(
                        title: widget.label,
                        initialValue: items[i],
                        validator: (val) =>
                            items.contains(val) && val != items[i] ? l10n.errorAlreadyExists : null,
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
