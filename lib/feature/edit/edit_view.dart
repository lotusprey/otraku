import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/feature/auth/login_instructions.dart';
import 'package:otraku/feature/settings/settings_model.dart';
import 'package:otraku/feature/viewer/persistence_provider.dart';
import 'package:otraku/localizations/gen.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/widget/input/stateful_tiles.dart';
import 'package:otraku/widget/layout/navigation_tool.dart';
import 'package:otraku/feature/collection/collection_models.dart';
import 'package:otraku/feature/edit/edit_buttons.dart';
import 'package:otraku/feature/edit/edit_model.dart';
import 'package:otraku/feature/edit/edit_provider.dart';
import 'package:otraku/widget/input/chip_selector.dart';
import 'package:otraku/feature/settings/settings_provider.dart';
import 'package:otraku/widget/input/date_field.dart';
import 'package:otraku/widget/grid/sliver_grid_delegates.dart';
import 'package:otraku/widget/loaders.dart';
import 'package:otraku/widget/input/number_field.dart';
import 'package:otraku/feature/edit/score_field.dart';
import 'package:otraku/widget/sheets.dart';
import 'package:otraku/extension/snack_bar_extension.dart';

class EditView extends ConsumerWidget {
  const EditView(this.tag, {this.callback});

  final EditTag tag;
  final void Function(EntryEdit)? callback;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final viewerId = ref.watch(viewerIdProvider);
    if (viewerId == null) {
      return SimpleSheet(
        builder: (context, scrollCtrl) => const Center(
          child: Padding(padding: Theming.paddingAll, child: LoginInstructions()),
        ),
      );
    }

    return switch (ref.watch(entryEditProvider(tag))) {
      AsyncData(:final value) => SheetWithButtonRow(
        buttons: EditButtons(ref, tag, value, callback),
        builder: (context, scrollCtrl) => _EditView(scrollCtrl, tag, value),
      ),
      AsyncError(:final error) => SheetWithButtonRow(
        buttons: EditButtons(ref, tag, null, callback),
        builder: (context, scrollCtrl) => Center(
          child: Padding(
            padding: Theming.paddingAll,
            child: Text(l10n.errorFailedLoading(error.toString())),
          ),
        ),
      ),
      AsyncLoading() => SheetWithButtonRow(
        buttons: EditButtons(ref, tag, null, callback),
        builder: (context, scrollCtrl) => const Center(
          child: Padding(padding: Theming.paddingAll, child: Loader()),
        ),
      ),
    };
  }
}

class _EditView extends ConsumerWidget {
  const _EditView(this.scrollCtrl, this.tag, this.entryEdit);

  final ScrollController scrollCtrl;
  final EditTag tag;
  final EntryEdit entryEdit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final readableNotifier = entryEditProvider(tag).notifier;

    final settings = ref.watch(settingsProvider.select((s) => s.value));
    final highContrast = ref.watch(persistenceProvider.select((s) => s.options.highContrast));

    final statusField = SliverToBoxAdapter(
      child: Padding(
        padding: const .symmetric(horizontal: Theming.offset),
        child: ChipSelector(
          title: l10n.entryStatus,
          items: ListStatus.values
              .map((v) => (v.localize(l10n, entryEdit.baseEntry.isAnime), v))
              .toList(),
          value: entryEdit.listStatus,
          highContrast: highContrast,
          onChanged: (status) => ref.read(readableNotifier).updateBy((s) {
            var startedAt = s.startedAt;
            var completedAt = s.completedAt;
            var progress = s.progress;

            if (entryEdit.baseEntry.listStatus == null && status == .current && startedAt == null) {
              startedAt = DateTime.now();
              SnackBarExtension.show(context, l10n.entryChangedDateStart);
            } else if (entryEdit.baseEntry.listStatus != status &&
                status == .completed &&
                completedAt == null) {
              completedAt = DateTime.now();
              var text = l10n.entryChangedDateCompletion;

              if (entryEdit.baseEntry.progressMax != null && progress < s.baseEntry.progressMax!) {
                progress = s.baseEntry.progressMax!;
                text = l10n.entryChangedDateCompletionAndProgress;
              }

              SnackBarExtension.show(context, text);
            }

            return s.copyWith(
              listStatus: status,
              progress: progress,
              startedAt: (startedAt,),
              completedAt: (completedAt,),
            );
          }),
        ),
      ),
    );

    final timelineFields = _FieldGrid(
      minWidth: 195,
      children: [
        DateField(
          label: l10n.entryDateStarted,
          value: entryEdit.startedAt,
          onChanged: (startedAt) => ref.read(readableNotifier).updateBy((s) {
            var listStatus = s.listStatus;

            if (startedAt != null && entryEdit.baseEntry.listStatus == null && listStatus == null) {
              listStatus = .current;
              SnackBarExtension.show(context, l10n.entryChangedStatus);
            }

            return s.copyWith(listStatus: listStatus, startedAt: (startedAt,));
          }),
        ),
        DateField(
          label: l10n.entryDateCompleted,
          value: entryEdit.completedAt,
          onChanged: (completedAt) => ref.read(readableNotifier).updateBy((s) {
            var listStatus = s.listStatus;
            var progress = s.progress;

            if (completedAt != null &&
                entryEdit.baseEntry.listStatus != .completed &&
                entryEdit.baseEntry.listStatus != .repeating &&
                entryEdit.baseEntry.listStatus == listStatus) {
              listStatus = .completed;
              String text = l10n.entryChangedStatus;

              if (s.baseEntry.progressMax != null && s.progress < s.baseEntry.progressMax!) {
                progress = s.baseEntry.progressMax!;
                text = l10n.entryChangedStatusAndProgress;
              }

              SnackBarExtension.show(context, text);
            }

            return s.copyWith(
              listStatus: listStatus,
              progress: progress,
              completedAt: (completedAt,),
            );
          }),
        ),
        NumberField(
          label: l10n.entryRepeats,
          value: entryEdit.repeat,
          onChanged: (repeat) => entryEdit.repeat = repeat,
        ),
      ],
    );

    return Material(
      color: Colors.transparent,
      child: CustomScrollView(
        controller: scrollCtrl,
        slivers: [
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
          statusField,
          const SliverToBoxAdapter(child: SizedBox(height: 15)),
          _buildProgressFields(context, ref, l10n),
          SliverToBoxAdapter(
            child: ScoreField(
              value: entryEdit.score,
              scoreFormat: settings?.scoreFormat,
              onChanged: (score) => entryEdit.score = score,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: Theming.offset)),
          _buildAdvancedScoringFields(ref, settings),
          const SliverToBoxAdapter(child: SizedBox(height: Theming.offset)),
          _Notes(l10n: l10n, value: entryEdit.notes, onChanged: (notes) => entryEdit.notes = notes),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
          timelineFields,
          SliverToBoxAdapter(
            child: StatefulCheckboxListTile(
              title: Text(l10n.entryPrivate),
              value: entryEdit.private,
              onChanged: (private) => entryEdit.private = private!,
            ),
          ),
          SliverToBoxAdapter(
            child: StatefulCheckboxListTile(
              title: Text(l10n.entryHiddenFromStatusLists),
              value: entryEdit.hiddenFromStatusLists,
              onChanged: (hiddenFromStatusLists) =>
                  entryEdit.hiddenFromStatusLists = hiddenFromStatusLists!,
            ),
          ),
          if (entryEdit.customLists.isNotEmpty)
            SliverToBoxAdapter(
              child: ExpansionTile(
                title: Text(l10n.entryCustomLists),
                initiallyExpanded: true,
                children: [
                  for (final e in entryEdit.customLists.entries)
                    StatefulCheckboxListTile(
                      title: Text(e.key),
                      value: e.value,
                      onChanged: (v) => entryEdit.customLists[e.key] = v!,
                    ),
                ],
              ),
            ),
          SliverToBoxAdapter(
            child: SizedBox(height: MediaQuery.paddingOf(context).bottom + BottomBar.height + 10),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressFields(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    final readableNotifier = entryEditProvider(tag).notifier;

    final progressField = NumberField(
      label: l10n.entryProgress,
      value: entryEdit.progress,
      maxValue: entryEdit.baseEntry.progressMax ?? 100000,
      onChanged: (progress) => ref.read(readableNotifier).updateBy((s) {
        var status = s.listStatus;
        var startedAt = s.startedAt;
        var completedAt = s.completedAt;

        String? text;
        if (progress == entryEdit.baseEntry.progressMax &&
            progress != entryEdit.baseEntry.progress) {
          if (entryEdit.baseEntry.listStatus == status && status != .completed) {
            status = .completed;
            text = l10n.entryChangedStatus;
          }

          if (entryEdit.baseEntry.completedAt == null && completedAt == null) {
            completedAt = DateTime.now();
            text = text == null
                ? l10n.entryChangedDateCompletion
                : l10n.entryChangedDateCompletionAndStatus;
          }
        } else if (entryEdit.baseEntry.progress == 0 && entryEdit.baseEntry.progress != progress) {
          if (entryEdit.baseEntry.listStatus == status && (status == null || status == .planning)) {
            status = .current;
            text = l10n.entryChangedStatus;
          }

          if (entryEdit.baseEntry.startedAt == null && startedAt == null) {
            startedAt = DateTime.now();
            text = text == null ? l10n.entryChangedDateStart : l10n.entryChangedDateStartAndStatus;
          }
        }

        if (text != null) SnackBarExtension.show(context, text);

        return s.copyWith(
          progress: progress,
          listStatus: status,
          startedAt: (startedAt,),
          completedAt: (completedAt,),
        );
      }),
    );

    Widget child = progressField;

    if (!entryEdit.baseEntry.isAnime) {
      final volumeProgressField = NumberField(
        label: l10n.entryProgressVolumes,
        value: entryEdit.progressVolumes,
        maxValue: entryEdit.baseEntry.progressVolumesMax ?? 100000,
        onChanged: (progressVolumes) => entryEdit.progressVolumes = progressVolumes,
      );

      child = MediaQuery.sizeOf(context).width < Theming.windowWidthMedium
          ? Column(
              mainAxisSize: .min,
              children: [progressField, const SizedBox(height: 20), volumeProgressField],
            )
          : Row(
              children: Theming.of(context).rightButtonOrientation
                  ? [
                      Expanded(child: volumeProgressField),
                      const SizedBox(width: Theming.offset),
                      Expanded(child: progressField),
                    ]
                  : [
                      Expanded(child: progressField),
                      const SizedBox(width: Theming.offset),
                      Expanded(child: volumeProgressField),
                    ],
            );
    }

    return SliverPadding(
      padding: const .only(left: Theming.offset, right: Theming.offset, bottom: Theming.offset),
      sliver: SliverToBoxAdapter(child: child),
    );
  }

  Widget _buildAdvancedScoringFields(WidgetRef ref, Settings? settings) {
    final advancedScoringEnabled = settings?.advancedScoringEnabled ?? false;
    final scoreFormat = settings?.scoreFormat ?? .point10;

    if (!advancedScoringEnabled || scoreFormat != .point100 && scoreFormat != .point10Decimal) {
      return const SliverToBoxAdapter(child: SizedBox());
    }

    final scores = entryEdit.advancedScores;
    final isDecimal = scoreFormat == .point10Decimal;

    final onChanged = (entry, score) {
      scores[entry.key] = score.toDouble();

      int count = 0;
      double avg = 0;
      for (final v in scores.values) {
        if (v > 0) {
          avg += v;
          count++;
        }
      }

      if (count > 0) avg /= count;

      if (entryEdit.score != avg) {
        ref.read(entryEditProvider(tag).notifier).updateBy((s) => s.copyWith(score: avg));
      }
    };

    return _FieldGrid(
      minWidth: 140,
      children: [
        for (final s in scores.entries)
          isDecimal
              ? NumberField.decimal(
                  label: s.key,
                  value: s.value,
                  maxValue: 10.0,
                  onChanged: (score) => onChanged(s, score),
                )
              : NumberField(
                  label: s.key,
                  value: s.value.toInt(),
                  maxValue: 100,
                  onChanged: (score) => onChanged(s, score),
                ),
      ],
    );
  }
}

class _FieldGrid extends StatelessWidget {
  const _FieldGrid({required this.minWidth, required this.children});

  final List<Widget> children;
  final double minWidth;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const .symmetric(horizontal: Theming.offset),
      sliver: SliverGrid(
        delegate: SliverChildListDelegate.fixed(children),
        gridDelegate: SliverGridDelegateWithMinWidthAndFixedHeight(minWidth: minWidth, height: 58),
      ),
    );
  }
}

class _Notes extends StatefulWidget {
  const _Notes({required this.l10n, required this.value, required this.onChanged});

  final String value;
  final void Function(String) onChanged;
  final AppLocalizations l10n;

  @override
  _NotesState createState() => _NotesState();
}

class _NotesState extends State<_Notes> {
  late final _ctrl = TextEditingController(text: widget.value);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SliverToBoxAdapter(
    child: Padding(
      padding: const .symmetric(horizontal: Theming.offset),
      child: TextField(
        minLines: 1,
        maxLines: 10,
        controller: _ctrl,
        style: TextTheme.of(context).bodyMedium,
        decoration: InputDecoration(
          labelText: widget.l10n.entryNotes,
          labelStyle: TextTheme.of(context).bodyMedium,
          border: const OutlineInputBorder(),
        ),
        onChanged: (value) => widget.onChanged(value),
      ),
    ),
  );
}
