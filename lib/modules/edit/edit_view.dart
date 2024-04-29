import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/common/widgets/fields/stateful_tiles.dart';
import 'package:otraku/common/widgets/layouts/bottom_bar.dart';
import 'package:otraku/modules/collection/collection_models.dart';
import 'package:otraku/modules/edit/edit_buttons.dart';
import 'package:otraku/modules/edit/edit_model.dart';
import 'package:otraku/modules/edit/edit_providers.dart';
import 'package:otraku/modules/media/media_constants.dart';
import 'package:otraku/modules/settings/settings_model.dart';
import 'package:otraku/modules/settings/settings_provider.dart';
import 'package:otraku/common/widgets/fields/date_field.dart';
import 'package:otraku/common/widgets/fields/drop_down_field.dart';
import 'package:otraku/common/widgets/fields/growable_text_field.dart';
import 'package:otraku/common/widgets/grids/sliver_grid_delegates.dart';
import 'package:otraku/common/widgets/loaders/loaders.dart';
import 'package:otraku/common/widgets/fields/labeled_field.dart';
import 'package:otraku/common/widgets/fields/number_field.dart';
import 'package:otraku/modules/edit/score_field.dart';
import 'package:otraku/common/widgets/overlays/dialogs.dart';
import 'package:otraku/common/widgets/overlays/sheets.dart';
import 'package:otraku/common/utils/toast.dart';

/// A sheet for entry editing. Should be opened with [showSheet].
class EditView extends StatelessWidget {
  const EditView(this.tag, {this.callback});

  final EditTag tag;
  final void Function(Edit)? callback;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        ref.listen<AsyncValue<Edit>>(
          oldEditProvider(tag),
          (_, s) => s.whenOrNull(
            error: (err, _) {
              Navigator.pop(context);
              showPopUp(
                context,
                ConfirmationDialog(
                  title: 'Failed to load edit sheet',
                  content: err.toString(),
                ),
              );
            },
          ),
        );

        return ref.watch(oldEditProvider(tag)).maybeWhen(
              data: (oldEdit) => _build(oldEdit),
              orElse: () => OpaqueSheetView(
                builder: (context, scrollCtrl) => const Center(child: Loader()),
              ),
            );
      },
    );
  }

  Widget _build(Edit oldEdit) {
    return OpaqueSheetView(
      buttons: EditButtons(tag, oldEdit, callback),
      builder: (context, scrollCtrl) => _EditView(scrollCtrl, tag, oldEdit),
    );
  }
}

class _EditView extends StatelessWidget {
  const _EditView(this.scrollCtrl, this.tag, this.oldEdit);

  final ScrollController scrollCtrl;
  final EditTag tag;
  final Edit oldEdit;

  @override
  Widget build(BuildContext context) {
    final provider = newEditProvider(tag);

    final tracking = _FieldGrid(
      minWidth: 140,
      children: [
        Consumer(
          builder: (context, ref, _) {
            final status = ref.watch(provider.select((s) => s.status));

            return DropDownField<EntryStatus?>(
              hint: 'Add',
              title: 'Status',
              value: status,
              items: Map.fromIterable(
                EntryStatus.values,
                key: (v) => v.format(oldEdit.type == 'ANIME'),
              ),
              onChanged: (status) => ref.read(provider.notifier).update(
                (s) {
                  var startedAt = s.startedAt;
                  var completedAt = s.completedAt;
                  var progress = s.progress;

                  if (oldEdit.status == null &&
                      status == EntryStatus.CURRENT &&
                      startedAt == null) {
                    startedAt = DateTime.now();
                    Toast.show(context, 'Start date changed');
                  } else if (oldEdit.status != status &&
                      status == EntryStatus.COMPLETED &&
                      completedAt == null) {
                    completedAt = DateTime.now();
                    var text = 'Completed date changed';

                    if (s.progressMax != null && progress < s.progressMax!) {
                      progress = s.progressMax!;
                      text = 'Completed date & progress changed';
                    }

                    Toast.show(context, text);
                  }

                  return s.copyWith(
                    status: status,
                    progress: progress,
                    startedAt: () => startedAt,
                    completedAt: () => completedAt,
                  );
                },
              ),
            );
          },
        ),
        LabeledField(
          label: 'Progress',
          child: Consumer(
            builder: (context, ref, _) {
              final progress = ref.watch(provider.select((s) => s.progress));

              return NumberField(
                value: progress,
                maxValue: oldEdit.progressMax ?? 100000,
                onChanged: (progress) {
                  ref.read(provider.notifier).update((s) {
                    var status = s.status;
                    var startedAt = s.startedAt;
                    var completedAt = s.completedAt;

                    String? text;
                    if (progress == s.progressMax &&
                        oldEdit.progress != progress) {
                      if (oldEdit.status == status &&
                          status != EntryStatus.COMPLETED) {
                        status = EntryStatus.COMPLETED;
                        text = 'Status changed';
                      }

                      if (oldEdit.completedAt == completedAt &&
                          completedAt == null) {
                        completedAt = DateTime.now();
                        text = text == null
                            ? 'Completed date changed'
                            : 'Status & Completed date changed';
                      }

                      if (text != null) Toast.show(context, text);
                    } else if (oldEdit.progress == 0 &&
                        oldEdit.progress != progress) {
                      if (oldEdit.status == status &&
                          (status == null || status == EntryStatus.PLANNING)) {
                        status = EntryStatus.CURRENT;
                        text = 'Status changed';
                      }

                      if (oldEdit.startedAt == null && startedAt == null) {
                        startedAt = DateTime.now();
                        text = text == null
                            ? 'Start date changed'
                            : 'Status & start date changed';
                      }
                    }
                    if (text != null) Toast.show(context, text);

                    return s.copyWith(
                      progress: progress.toInt(),
                      status: status,
                      startedAt: () => startedAt,
                      completedAt: () => completedAt,
                    );
                  });
                },
              );
            },
          ),
        ),
        LabeledField(
          label: 'Repeat',
          child: Consumer(
            builder: (context, ref, _) => NumberField(
              value: ref.read(provider).repeat,
              onChanged: (repeat) => ref
                  .read(provider.notifier)
                  .update((s) => s.copyWith(repeat: repeat.toInt())),
            ),
          ),
        ),
        if (oldEdit.type != 'ANIME')
          LabeledField(
            label: 'Progress Volumes',
            child: Consumer(
              builder: (context, ref, _) => NumberField(
                value: ref.read(provider).progressVolumes,
                maxValue: oldEdit.progressVolumesMax ?? 100000,
                onChanged: (progressVolumes) =>
                    ref.read(provider.notifier).update(
                          (s) => s.copyWith(
                            progressVolumes: progressVolumes.toInt(),
                          ),
                        ),
              ),
            ),
          ),
      ],
    );

    final dates = _FieldGrid(
      minWidth: 165,
      children: [
        LabeledField(
          label: 'Started',
          child: Consumer(
            builder: (context, ref, _) {
              final startedAt = ref.watch(provider.select((s) => s.startedAt));

              return DateField(
                date: startedAt,
                onChanged: (startedAt) {
                  ref.read(provider.notifier).update((s) {
                    var status = s.status;

                    if (startedAt != null &&
                        oldEdit.status == null &&
                        status == null) {
                      status = EntryStatus.CURRENT;
                      Toast.show(context, 'Status changed');
                    }

                    return s.copyWith(
                      status: status,
                      startedAt: () => startedAt,
                    );
                  });
                },
              );
            },
          ),
        ),
        LabeledField(
          label: 'Completed',
          child: Consumer(
            builder: (context, ref, _) {
              final completedAt =
                  ref.watch(provider.select((s) => s.completedAt));

              return DateField(
                date: completedAt,
                onChanged: (completedAt) {
                  ref.read(provider.notifier).update((s) {
                    var status = s.status;
                    var progress = s.progress;

                    if (completedAt != null &&
                        oldEdit.status != EntryStatus.COMPLETED &&
                        oldEdit.status != EntryStatus.REPEATING &&
                        oldEdit.status == status) {
                      status = EntryStatus.COMPLETED;
                      String text = 'Status changed';

                      if (s.progressMax != null &&
                          s.progress < s.progressMax!) {
                        progress = s.progressMax!;
                        text = 'Status & progress changed';
                      }

                      Toast.show(context, text);
                    }

                    return s.copyWith(
                      status: status,
                      progress: progress,
                      completedAt: () => completedAt,
                    );
                  });
                },
              );
            },
          ),
        ),
      ],
    );

    final advancedScoring = Consumer(
      builder: (context, ref, _) {
        final settings =
            ref.watch(settingsProvider).valueOrNull ?? Settings.empty();

        if (!settings.advancedScoringEnabled ||
            settings.scoreFormat != ScoreFormat.point100 &&
                settings.scoreFormat != ScoreFormat.point10Decimal) {
          return const SliverToBoxAdapter(child: SizedBox());
        }

        final scores = ref.watch(provider.notifier).state.advancedScores;
        final isDecimal = settings.scoreFormat == ScoreFormat.point10Decimal;

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

          final notifier = ref.read(provider.notifier);
          if (notifier.state.score != avg) {
            notifier.update((s) => s.copyWith(score: avg));
          }
        };

        return _FieldGrid(
          minWidth: 140,
          children: [
            for (final s in scores.entries)
              LabeledField(
                label: s.key,
                child: isDecimal
                    ? DecimalNumberField(
                        value: s.value,
                        maxValue: 10.0,
                        onChanged: (score) => onChanged(s, score),
                      )
                    : NumberField(
                        value: s.value.toInt(),
                        maxValue: 100,
                        onChanged: (score) => onChanged(s, score),
                      ),
              ),
          ],
        );
      },
    );

    const space = SliverToBoxAdapter(child: SizedBox(height: 10));

    return Material(
      child: Consumer(
        builder: (context, ref, _) {
          final notifier = ref.watch(provider.notifier);

          return CustomScrollView(
            controller: scrollCtrl,
            slivers: [
              space,
              space,
              tracking,
              space,
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: LabeledField(label: 'Score', child: ScoreField(tag)),
                ),
              ),
              space,
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: LabeledField(
                    label: 'Notes',
                    child: GrowableTextField(
                      text: notifier.state.notes,
                      onChanged: (notes) => notifier.state.notes = notes,
                    ),
                  ),
                ),
              ),
              space,
              dates,
              space,
              advancedScoring,
              space,
              SliverToBoxAdapter(
                child: StatefulCheckboxListTile(
                  title: const Text('Private'),
                  value: notifier.state.private,
                  onChanged: (v) => notifier.update(
                    (s) => s.copyWith(private: v),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: StatefulCheckboxListTile(
                  title: const Text('Hidden From Status Lists'),
                  value: notifier.state.hiddenFromStatusLists,
                  onChanged: (v) => notifier.update(
                    (s) => s.copyWith(hiddenFromStatusLists: v),
                  ),
                ),
              ),
              if (notifier.state.customLists.isNotEmpty)
                SliverToBoxAdapter(
                  child: ExpansionTile(
                    title: const Text('Custom Lists'),
                    initiallyExpanded: true,
                    children: [
                      for (final e in notifier.state.customLists.entries)
                        StatefulCheckboxListTile(
                          title: Text(e.key),
                          value: e.value,
                          onChanged: (v) =>
                              notifier.state.customLists[e.key] = v!,
                        ),
                    ],
                  ),
                ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: MediaQuery.paddingOf(context).bottom +
                      BottomBar.height +
                      10,
                ),
              )
            ],
          );
        },
      ),
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
      padding: const EdgeInsets.symmetric(horizontal: 10),
      sliver: SliverGrid(
        delegate: SliverChildListDelegate.fixed(children),
        gridDelegate: SliverGridDelegateWithMinWidthAndFixedHeight(
          minWidth: minWidth,
          height: 71,
        ),
      ),
    );
  }
}
