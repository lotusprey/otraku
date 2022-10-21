import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/collection/collection_models.dart';
import 'package:otraku/utils/consts.dart';
import 'package:otraku/edit/edit_buttons.dart';
import 'package:otraku/edit/edit_model.dart';
import 'package:otraku/edit/edit_providers.dart';
import 'package:otraku/media/media_constants.dart';
import 'package:otraku/settings/settings_provider.dart';
import 'package:otraku/utils/convert.dart';
import 'package:otraku/widgets/fields/checkbox_field.dart';
import 'package:otraku/widgets/fields/date_field.dart';
import 'package:otraku/widgets/fields/drop_down_field.dart';
import 'package:otraku/widgets/fields/growable_text_field.dart';
import 'package:otraku/widgets/grids/sliver_grid_delegates.dart';
import 'package:otraku/widgets/loaders.dart/loaders.dart';
import 'package:otraku/widgets/fields/labeled_field.dart';
import 'package:otraku/widgets/fields/number_field.dart';
import 'package:otraku/edit/score_field.dart';
import 'package:otraku/widgets/overlays/dialogs.dart';
import 'package:otraku/widgets/overlays/sheets.dart';
import 'package:otraku/widgets/overlays/toast.dart';

/// A sheet for entry editing. Should be opened with [showSheet].
class EditView extends StatelessWidget {
  const EditView(
    this.mediaId, {
    this.edit,
    this.callback,
    this.complete = false,
  });

  final int mediaId;
  final Edit? edit;
  final void Function(Edit)? callback;
  final bool complete;

  @override
  Widget build(BuildContext context) {
    if (edit != null) {
      return Consumer(
        builder: (context, ref, _) {
          final notifier = ref.watch(editProvider.notifier);

          if (notifier.state.mediaId < 0) {
            notifier.update((_) => edit!.copy(complete));
          }

          return _build(edit!);
        },
      );
    }

    return Consumer(
      builder: (context, ref, _) {
        final notifier = ref.watch(editProvider.notifier);

        ref.listen<AsyncValue<Edit>>(
          currentEditProvider(mediaId),
          (_, state) => state.whenOrNull(
            data: (data) {
              if (notifier.state.mediaId < 0) {
                notifier.update((_) => data.copy(complete));
              }
            },
            error: (err, _) {
              Navigator.pop(context);
              showPopUp(
                context,
                ConfirmationDialog(
                  title: 'Could not load edit sheet',
                  content: err.toString(),
                ),
              );
            },
          ),
        );

        return ref.watch(currentEditProvider(mediaId)).maybeWhen(
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
      buttons: EditButtons(mediaId, oldEdit, callback),
      builder: (context, scrollCtrl) => _EditView(scrollCtrl, oldEdit),
    );
  }
}

class _EditView extends StatelessWidget {
  const _EditView(this.scrollCtrl, this.oldEdit);

  final ScrollController scrollCtrl;
  final Edit oldEdit;

  @override
  Widget build(BuildContext context) {
    final tracking = _FieldGrid(
      minWidth: 140,
      children: [
        Consumer(
          builder: (context, ref, _) {
            final status = ref.watch(editProvider.select((s) => s.status));

            return DropDownField<EntryStatus?>(
              hint: 'Add',
              title: 'Status',
              value: status,
              items: Map.fromIterable(
                EntryStatus.values,
                key: (v) => Convert.adaptListStatus(v, oldEdit.type == 'ANIME'),
              ),
              onChanged: (status) => ref.read(editProvider.notifier).update(
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
              final progress = ref.watch(
                editProvider.select((s) => s.progress),
              );

              return NumberField(
                initial: progress,
                maxValue: oldEdit.progressMax ?? 100000,
                onChanged: (progress) {
                  ref.read(editProvider.notifier).update((s) {
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
              initial: ref.read(editProvider).repeat,
              onChanged: (repeat) => ref
                  .read(editProvider.notifier)
                  .update((s) => s.copyWith(repeat: repeat.toInt())),
            ),
          ),
        ),
        if (oldEdit.type != 'ANIME')
          LabeledField(
            label: 'Progress Volumes',
            child: Consumer(
              builder: (context, ref, _) => NumberField(
                initial: ref.read(editProvider).progressVolumes,
                maxValue: oldEdit.progressVolumesMax ?? 100000,
                onChanged: (progressVolumes) =>
                    ref.read(editProvider.notifier).update(
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
              final startedAt = ref.watch(
                editProvider.select((s) => s.startedAt),
              );

              return DateField(
                date: startedAt,
                onChanged: (startedAt) {
                  ref.read(editProvider.notifier).update((s) {
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
              final completedAt = ref.watch(
                editProvider.select((s) => s.completedAt),
              );

              return DateField(
                date: completedAt,
                onChanged: (completedAt) {
                  ref.read(editProvider.notifier).update((s) {
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
        final settings = ref.watch(settingsProvider);

        if (!settings.advancedScoringEnabled ||
            settings.scoreFormat != ScoreFormat.POINT_100 &&
                settings.scoreFormat != ScoreFormat.POINT_10_DECIMAL) {
          return const SliverToBoxAdapter(child: SizedBox());
        }

        final scores = ref.watch(editProvider.notifier).state.advancedScores;

        return _FieldGrid(
          minWidth: 140,
          children: [
            for (final s in scores.entries)
              LabeledField(
                label: s.key,
                child: NumberField(
                  initial: s.value,
                  maxValue: 100,
                  onChanged: (score) {
                    scores[s.key] = score.toDouble();

                    int count = 0;
                    double avg = 0;
                    for (final v in scores.values) {
                      if (v > 0) {
                        avg += v;
                        count++;
                      }
                    }

                    if (count > 0) avg /= count;

                    final notifier = ref.read(editProvider.notifier);
                    if (notifier.state.score != avg) {
                      notifier.update((s) => s.copyWith(score: avg));
                    }
                  },
                ),
              ),
          ],
        );
      },
    );

    final advancedSettings = Consumer(
      builder: (context, ref, _) {
        final notifier = ref.watch(editProvider.notifier);

        return _CheckBoxGrid(
          {
            'Private': notifier.state.private,
            'Hidden From Status Lists': notifier.state.hiddenFromStatusLists,
          },
          (key, val) => key == 'Private'
              ? notifier.update((s) => s.copyWith(private: val))
              : notifier.update((s) => s.copyWith(hiddenFromStatusLists: val)),
        );
      },
    );

    const space = SliverToBoxAdapter(child: SizedBox(height: 10));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Consumer(
        builder: (context, ref, _) {
          final notifier = ref.watch(editProvider.notifier);

          return CustomScrollView(
            controller: scrollCtrl,
            slivers: [
              space,
              space,
              tracking,
              space,
              const SliverToBoxAdapter(
                child: LabeledField(label: 'Score', child: ScoreField()),
              ),
              space,
              SliverToBoxAdapter(
                child: LabeledField(
                  label: 'Notes',
                  child: Padding(
                    padding: const EdgeInsets.only(top: 5),
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
              const _Label('Additional Settings'),
              advancedSettings,
              if (notifier.state.customLists.isNotEmpty) ...[
                space,
                const _Label('Custom Lists'),
                _CheckBoxGrid(
                  notifier.state.customLists,
                  (key, val) => notifier.state.customLists[key] = val,
                ),
              ],
              const SliverToBoxAdapter(child: SizedBox(height: 60)),
            ],
          );
        },
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Text(label, style: Theme.of(context).textTheme.subtitle1),
    );
  }
}

class _FieldGrid extends StatelessWidget {
  const _FieldGrid({required this.minWidth, required this.children});

  final List<Widget> children;
  final double minWidth;

  @override
  Widget build(BuildContext context) {
    return SliverGrid(
      delegate: SliverChildListDelegate.fixed(children),
      gridDelegate: SliverGridDelegateWithMinWidthAndFixedHeight(
        minWidth: minWidth,
        height: 71,
      ),
    );
  }
}

class _CheckBoxGrid extends StatelessWidget {
  const _CheckBoxGrid(this.map, this.onChanged);

  final Map<String, bool> map;
  final Function(String, bool) onChanged;

  @override
  Widget build(BuildContext context) {
    if (map.isEmpty) return const SliverToBoxAdapter();

    return SliverGrid(
      delegate: SliverChildBuilderDelegate(
        (_, index) => CheckBoxField(
          title: map.entries.elementAt(index).key,
          initial: map.entries.elementAt(index).value,
          onChanged: (val) => onChanged(map.entries.elementAt(index).key, val),
        ),
        childCount: map.length,
      ),
      gridDelegate: const SliverGridDelegateWithMinWidthAndFixedHeight(
        minWidth: 180,
        mainAxisSpacing: 0,
        height: Consts.tapTargetSize,
      ),
    );
  }
}
