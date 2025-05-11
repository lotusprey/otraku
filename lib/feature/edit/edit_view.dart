import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/feature/settings/settings_model.dart';
import 'package:otraku/feature/viewer/persistence_provider.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/widget/input/stateful_tiles.dart';
import 'package:otraku/widget/layout/navigation_tool.dart';
import 'package:otraku/feature/collection/collection_models.dart';
import 'package:otraku/feature/edit/edit_buttons.dart';
import 'package:otraku/feature/edit/edit_model.dart';
import 'package:otraku/feature/edit/edit_provider.dart';
import 'package:otraku/widget/input/chip_selector.dart';
import 'package:otraku/feature/media/media_models.dart';
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
    final viewerId = ref.watch(viewerIdProvider);
    if (viewerId == null) {
      return SimpleSheet(
        builder: (context, scrollCtrl) => const Center(
          child: Padding(
            padding: Theming.paddingAll,
            child: Text('Log in to edit media'),
          ),
        ),
      );
    }

    return switch (ref.watch(entryEditProvider(tag))) {
      AsyncData(:final value) => SheetWithButtonRow(
          buttons: EditButtons(ref, tag, value, callback),
          builder: (context, scrollCtrl) => _EditView(
            scrollCtrl,
            tag,
            value,
          ),
        ),
      AsyncError(:final error) => SheetWithButtonRow(
          buttons: EditButtons(ref, tag, null, callback),
          builder: (context, scrollCtrl) => Center(
            child: Padding(
              padding: Theming.paddingAll,
              child: Text('Failed to load edit sheet: $error'),
            ),
          ),
        ),
      _ => SheetWithButtonRow(
          buttons: EditButtons(ref, tag, null, callback),
          builder: (context, scrollCtrl) => const Center(
            child: Padding(
              padding: Theming.paddingAll,
              child: Loader(),
            ),
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
    final readableNotifier = entryEditProvider(tag).notifier;

    final settings = ref.watch(
      settingsProvider.select((s) => s.valueOrNull),
    );

    final statusField = SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Theming.offset),
        child: ChipSelector(
          title: 'Status',
          items: ListStatus.values
              .map((v) => (v.label(entryEdit.baseEntry.isAnime), v))
              .toList(),
          value: entryEdit.listStatus,
          onChanged: (status) => ref.read(readableNotifier).updateBy(
            (s) {
              var startedAt = s.startedAt;
              var completedAt = s.completedAt;
              var progress = s.progress;

              if (entryEdit.baseEntry.listStatus == null &&
                  status == ListStatus.current &&
                  startedAt == null) {
                startedAt = DateTime.now();
                SnackBarExtension.show(context, 'Start date changed');
              } else if (entryEdit.baseEntry.listStatus != status &&
                  status == ListStatus.completed &&
                  completedAt == null) {
                completedAt = DateTime.now();
                var text = 'Completed date changed';

                if (entryEdit.baseEntry.progressMax != null &&
                    progress < s.baseEntry.progressMax!) {
                  progress = s.baseEntry.progressMax!;
                  text = 'Completed date & progress changed';
                }

                SnackBarExtension.show(context, text);
              }

              return s.copyWith(
                listStatus: status,
                progress: progress,
                startedAt: (startedAt,),
                completedAt: (completedAt,),
              );
            },
          ),
        ),
      ),
    );

    final timelineFields = _FieldGrid(
      minWidth: 195,
      children: [
        DateField(
          label: 'Started',
          value: entryEdit.startedAt,
          onChanged: (startedAt) => ref.read(readableNotifier).updateBy((s) {
            var listStatus = s.listStatus;

            if (startedAt != null &&
                entryEdit.baseEntry.listStatus == null &&
                listStatus == null) {
              listStatus = ListStatus.current;
              SnackBarExtension.show(context, 'Status changed');
            }

            return s.copyWith(listStatus: listStatus, startedAt: (startedAt,));
          }),
        ),
        DateField(
          label: 'Completed',
          value: entryEdit.completedAt,
          onChanged: (completedAt) => ref.read(readableNotifier).updateBy((s) {
            var listStatus = s.listStatus;
            var progress = s.progress;

            if (completedAt != null &&
                entryEdit.baseEntry.listStatus != ListStatus.completed &&
                entryEdit.baseEntry.listStatus != ListStatus.repeating &&
                entryEdit.baseEntry.listStatus == listStatus) {
              listStatus = ListStatus.completed;
              String text = 'Status changed';

              if (s.baseEntry.progressMax != null &&
                  s.progress < s.baseEntry.progressMax!) {
                progress = s.baseEntry.progressMax!;
                text = 'Status & progress changed';
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
          label: 'Repeat',
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
          _buildProgressFields(context, ref),
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
          _Notes(
            value: entryEdit.notes,
            onChanged: (notes) => entryEdit.notes = notes,
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
          timelineFields,
          SliverToBoxAdapter(
            child: StatefulCheckboxListTile(
              title: const Text('Private'),
              value: entryEdit.private,
              onChanged: (private) => entryEdit.private = private!,
            ),
          ),
          SliverToBoxAdapter(
            child: StatefulCheckboxListTile(
              title: const Text('Hidden From Status Lists'),
              value: entryEdit.hiddenFromStatusLists,
              onChanged: (hiddenFromStatusLists) =>
                  entryEdit.hiddenFromStatusLists = hiddenFromStatusLists!,
            ),
          ),
          if (entryEdit.customLists.isNotEmpty)
            SliverToBoxAdapter(
              child: ExpansionTile(
                title: const Text('Custom Lists'),
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
            child: SizedBox(
              height:
                  MediaQuery.paddingOf(context).bottom + BottomBar.height + 10,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildProgressFields(BuildContext context, WidgetRef ref) {
    final readableNotifier = entryEditProvider(tag).notifier;

    final leftHanded = ref.watch(
      persistenceProvider.select((s) => s.options.leftHanded),
    );

    final progressField = NumberField(
      label: 'Progress',
      value: entryEdit.progress,
      maxValue: entryEdit.baseEntry.progressMax ?? 100000,
      onChanged: (progress) => ref.read(readableNotifier).updateBy((s) {
        var status = s.listStatus;
        var startedAt = s.startedAt;
        var completedAt = s.completedAt;

        String? text;
        if (progress == entryEdit.baseEntry.progressMax &&
            progress != entryEdit.baseEntry.progress) {
          if (entryEdit.baseEntry.listStatus == status &&
              status != ListStatus.completed) {
            status = ListStatus.completed;
            text = 'Status changed';
          }

          if (entryEdit.baseEntry.completedAt == null && completedAt == null) {
            completedAt = DateTime.now();
            text = text == null
                ? 'Completed date changed'
                : 'Status & Completed date changed';
          }
        } else if (entryEdit.baseEntry.progress == 0 &&
            entryEdit.baseEntry.progress != progress) {
          if (entryEdit.baseEntry.listStatus == status &&
              (status == null || status == ListStatus.planning)) {
            status = ListStatus.current;
            text = 'Status changed';
          }

          if (entryEdit.baseEntry.startedAt == null && startedAt == null) {
            startedAt = DateTime.now();
            text = text == null
                ? 'Start date changed'
                : 'Status & start date changed';
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
        label: 'Volume Progress',
        value: entryEdit.progressVolumes,
        maxValue: entryEdit.baseEntry.progressVolumesMax ?? 100000,
        onChanged: (progressVolumes) =>
            entryEdit.progressVolumes = progressVolumes,
      );

      child = MediaQuery.sizeOf(context).width < Theming.windowWidthMedium
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                progressField,
                const SizedBox(height: 20),
                volumeProgressField,
              ],
            )
          : Row(
              children: leftHanded
                  ? [
                      Expanded(child: progressField),
                      const SizedBox(width: Theming.offset),
                      Expanded(child: volumeProgressField),
                    ]
                  : [
                      Expanded(child: volumeProgressField),
                      const SizedBox(width: Theming.offset),
                      Expanded(child: progressField),
                    ],
            );
    }

    return SliverPadding(
      padding: const EdgeInsets.only(
        left: Theming.offset,
        right: Theming.offset,
        bottom: Theming.offset,
      ),
      sliver: SliverToBoxAdapter(child: child),
    );
  }

  Widget _buildAdvancedScoringFields(WidgetRef ref, Settings? settings) {
    final advancedScoringEnabled = settings?.advancedScoringEnabled ?? false;
    final scoreFormat = settings?.scoreFormat ?? ScoreFormat.point10;

    if (!advancedScoringEnabled ||
        scoreFormat != ScoreFormat.point100 &&
            scoreFormat != ScoreFormat.point10Decimal) {
      return const SliverToBoxAdapter(child: SizedBox());
    }

    final scores = entryEdit.advancedScores;
    final isDecimal = scoreFormat == ScoreFormat.point10Decimal;

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
        ref
            .read(entryEditProvider(tag).notifier)
            .updateBy((s) => s.copyWith(score: avg));
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
      padding: const EdgeInsets.symmetric(horizontal: Theming.offset),
      sliver: SliverGrid(
        delegate: SliverChildListDelegate.fixed(children),
        gridDelegate: SliverGridDelegateWithMinWidthAndFixedHeight(
          minWidth: minWidth,
          height: 58,
        ),
      ),
    );
  }
}

class _Notes extends StatefulWidget {
  const _Notes({required this.value, required this.onChanged});

  final String value;
  final void Function(String) onChanged;

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
          padding: const EdgeInsets.symmetric(horizontal: Theming.offset),
          child: TextField(
            minLines: 1,
            maxLines: 10,
            controller: _ctrl,
            style: TextTheme.of(context).bodyMedium,
            decoration: const InputDecoration(
              labelText: 'Notes',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) => widget.onChanged(value),
          ),
        ),
      );
}
