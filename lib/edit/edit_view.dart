import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/controllers/collection_controller.dart';
import 'package:otraku/constants/list_status.dart';
import 'package:otraku/constants/score_format.dart';
import 'package:otraku/constants/consts.dart';
import 'package:otraku/edit/edit.dart';
import 'package:otraku/settings/user_settings.dart';
import 'package:otraku/utils/convert.dart';
import 'package:otraku/utils/settings.dart';
import 'package:otraku/widgets/fields/checkbox_field.dart';
import 'package:otraku/widgets/fields/date_field.dart';
import 'package:otraku/widgets/fields/drop_down_field.dart';
import 'package:otraku/widgets/fields/growable_text_field.dart';
import 'package:otraku/widgets/grids/sliver_grid_delegates.dart';
import 'package:otraku/widgets/loaders.dart/loaders.dart';
import 'package:otraku/widgets/fields/labeled_field.dart';
import 'package:otraku/widgets/fields/number_field.dart';
import 'package:otraku/widgets/fields/score_field.dart';
import 'package:otraku/widgets/overlays/dialogs.dart';
import 'package:otraku/widgets/overlays/sheets.dart';
import 'package:otraku/widgets/overlays/toast.dart';

/// A sheet for entry editing. Should be opened with [showSheet].
class EditView extends StatelessWidget {
  EditView(
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

          if (notifier.state.mediaId < 0)
            notifier.update((_) => _resolveData(edit!));

          return _build(edit!);
        },
      );
    }

    return Consumer(
      builder: (context, ref, _) {
        ref.listen<AsyncValue<Edit>>(
          currentEditProvider(mediaId),
          (_, state) => state.whenOrNull(
            data: (data) {
              final notifier = ref.watch(editProvider.notifier);

              if (notifier.state.mediaId < 0)
                notifier.update((_) => _resolveData(data));
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

  Edit _resolveData(Edit data) {
    if (!complete) return data;

    return data.copyWith(
      status: ListStatus.COMPLETED,
      completedAt: DateTime.now,
      progress: data.progressMax,
      progressVolumes: data.progressVolumesMax,
    );
  }

  Widget _build(Edit oldEdit) {
    return OpaqueSheetView(
      buttons: [
        if (oldEdit.status != null)
          _RemoveButton(oldEdit, callback)
        else
          const Spacer(),
        _SaveButton(mediaId, oldEdit, callback),
      ],
      builder: (context, scrollCtrl) => _EditView(scrollCtrl, oldEdit),
    );
  }
}

class _RemoveButton extends StatelessWidget {
  _RemoveButton(this.oldEdit, this.callback);

  final Edit oldEdit;
  final void Function(Edit)? callback;

  @override
  Widget build(BuildContext context) {
    return OpaqueSheetViewButton(
      text: 'Remove',
      icon: Ionicons.trash_bin_outline,
      warning: true,
      onTap: () => showPopUp(
        context,
        ConfirmationDialog(
          title: 'Remove entry?',
          mainAction: 'Yes',
          secondaryAction: 'No',
          onConfirm: () {
            Get.find<CollectionController>(
              tag: oldEdit.type == 'ANIME'
                  ? '${Settings().id}true'
                  : '${Settings().id}false',
            ).removeEntry(oldEdit);
            // TODO remove item
            // if (ctrl.model!.status == ListStatus.CURRENT)
            //           Get.find<ProgressController>()
            //               .remove(ctrl.model!.mediaId);

            callback?.call(oldEdit.emptyCopy());
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}

class _SaveButton extends StatefulWidget {
  _SaveButton(this.mediaId, this.oldEdit, this.callback);

  final int mediaId;
  final Edit oldEdit;
  final void Function(Edit)? callback;

  @override
  __SaveButtonState createState() => __SaveButtonState();
}

class __SaveButtonState extends State<_SaveButton> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Expanded(child: Center(child: Loader()));

    return Consumer(
      builder: (__, ref, _) => OpaqueSheetViewButton(
        text: 'Save',
        icon: Ionicons.save_outline,
        onTap: () {
          final newEdit = ref.read(editProvider);
          setState(() => _loading = true);

          Get.find<CollectionController>(
            tag: widget.oldEdit.type == 'ANIME'
                ? '${Settings().id}true'
                : '${Settings().id}false',
          ).updateEntry(widget.oldEdit, newEdit).then((_) {
            widget.callback?.call(newEdit);
            Navigator.pop(context);
          });
        },
      ),
    );
  }
}

class _EditView extends StatelessWidget {
  _EditView(this.scrollCtrl, this.oldEdit);

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

            return DropDownField<ListStatus?>(
              hint: 'Add',
              title: 'Status',
              value: status,
              items: Map.fromIterable(
                ListStatus.values,
                key: (v) => Convert.adaptListStatus(v, oldEdit.type == 'ANIME'),
              ),
              onChanged: (status) => ref.read(editProvider.notifier).update(
                (s) {
                  var startedAt = s.startedAt;
                  var completedAt = s.completedAt;
                  var progress = s.progress;

                  if (oldEdit.status == null &&
                      status == ListStatus.CURRENT &&
                      startedAt == null) {
                    startedAt = DateTime.now();
                    Toast.show(context, 'Start date changed');
                  } else if (oldEdit.status != status &&
                      status == ListStatus.COMPLETED &&
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
                          status != ListStatus.COMPLETED) {
                        status = ListStatus.COMPLETED;
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
                          (status == null || status == ListStatus.PLANNING)) {
                        status = ListStatus.CURRENT;
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
                      status = ListStatus.CURRENT;
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
                        oldEdit.status != ListStatus.COMPLETED &&
                        oldEdit.status != ListStatus.REPEATING &&
                        oldEdit.status == status) {
                      status = ListStatus.COMPLETED;
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
        final settings = ref.watch(userSettingsProvider);

        if (!settings.advancedScoringEnabled ||
            settings.scoreFormat != ScoreFormat.POINT_100 &&
                settings.scoreFormat != ScoreFormat.POINT_10_DECIMAL)
          return const SizedBox();

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
                    for (final v in scores.values)
                      if (v > 0) {
                        avg += v;
                        count++;
                      }

                    if (count > 0) avg /= count;

                    final notifier = ref.read(editProvider.notifier);
                    if (notifier.state.score != avg)
                      notifier.update((s) => s.copyWith(score: avg));
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
                  child: GrowableTextField(
                    text: notifier.state.notes,
                    onChanged: (notes) => notifier.state.notes = notes,
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
  _FieldGrid({required this.minWidth, required this.children});

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
  _CheckBoxGrid(this.map, this.onChanged);

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
