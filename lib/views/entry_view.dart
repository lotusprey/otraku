import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/controllers/collection_controller.dart';
import 'package:otraku/controllers/entry_controller.dart';
import 'package:otraku/controllers/viewer_controller.dart';
import 'package:otraku/enums/list_status.dart';
import 'package:otraku/enums/score_format.dart';
import 'package:otraku/models/entry_model.dart';
import 'package:otraku/models/settings_model.dart';
import 'package:otraku/utils/config.dart';
import 'package:otraku/widgets/fields/checkbox_field.dart';
import 'package:otraku/widgets/fields/date_field.dart';
import 'package:otraku/widgets/fields/drop_down_field.dart';
import 'package:otraku/widgets/fields/expandable_field.dart';
import 'package:otraku/widgets/layouts/sliver_grid_delegates.dart';
import 'package:otraku/widgets/loaders.dart/loader.dart';
import 'package:otraku/widgets/navigation/app_bars.dart';
import 'package:otraku/widgets/fields/input_field_structure.dart';
import 'package:otraku/widgets/fields/number_field.dart';
import 'package:otraku/widgets/fields/score_picker.dart';
import 'package:otraku/widgets/overlays/dialogs.dart';
import 'package:otraku/widgets/overlays/toast.dart';

class EntryView extends StatelessWidget {
  final int mediaId;
  final Function(EntryModel)? callback;

  EntryView(this.mediaId, this.callback);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<EntryController>(
      id: EntryController.MAIN_ID,
      tag: mediaId.toString(),
      builder: (entryCtrl) {
        final model = entryCtrl.model;

        return Scaffold(
          appBar: ShadowAppBar(
            title: 'Edit',
            actions: [_Actions(entryCtrl, callback)],
          ),
          body: model != null
              ? _Content(entryCtrl, Get.find<ViewerController>().settings!)
              : const Center(child: Loader()),
        );
      },
    );
  }
}

class _Actions extends StatefulWidget {
  final EntryController ctrl;
  final Function(EntryModel)? callback;

  _Actions(this.ctrl, this.callback);
  @override
  __ActionsState createState() => __ActionsState();
}

class __ActionsState extends State<_Actions> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final ctrl = widget.ctrl;
    final actions = <Widget>[];

    if (ctrl.model != null) {
      if (_loading)
        actions.add(const Padding(padding: Config.PADDING, child: Loader()));
      else {
        if (ctrl.model!.entryId != null)
          actions.add(AppBarIcon(
            icon: Ionicons.trash_bin_outline,
            tooltip: 'Remove',
            onTap: () => showPopUp(
              context,
              ConfirmationDialog(
                title: 'Remove entry?',
                mainAction: 'Yes',
                secondaryAction: 'No',
                onConfirm: () {
                  Get.find<CollectionController>(
                    tag: ctrl.model!.type == 'ANIME'
                        ? CollectionController.ANIME
                        : CollectionController.MANGA,
                  ).removeEntry(ctrl.oldModel!);
                  widget.callback?.call(EntryModel.empty(ctrl.model!));
                  Navigator.of(context).pop();
                },
              ),
            ),
          ));

        actions.add(AppBarIcon(
            icon: Ionicons.save_outline,
            tooltip: 'Save',
            onTap: () {
              setState(() => _loading = true);
              Get.find<CollectionController>(
                tag: ctrl.model!.type == 'ANIME'
                    ? CollectionController.ANIME
                    : CollectionController.MANGA,
              ).updateEntry(ctrl.oldModel!, ctrl.model!).then((_) {
                widget.callback?.call(ctrl.model!);
                Navigator.of(context).pop();
              });
            }));
      }
    }

    return Row(children: actions);
  }
}

class _Content extends StatelessWidget {
  final EntryController entry;
  final SettingsModel settings;
  _Content(this.entry, this.settings);

  @override
  Widget build(BuildContext context) {
    final old = entry.oldModel!;
    final model = entry.model!;

    final advancedScoring = <Widget>[];
    if (settings.advancedScoringEnabled &&
        (settings.scoreFormat == ScoreFormat.POINT_100 ||
            settings.scoreFormat == ScoreFormat.POINT_10_DECIMAL)) {
      advancedScoring.add(
        const SliverToBoxAdapter(child: SizedBox(height: 10)),
      );

      final fields = <Widget>[];
      for (final s in model.advancedScores.entries)
        fields.add(InputFieldStructure(
          title: s.key,
          child: NumberField(
            value: s.value,
            maxValue: 100,
            update: (score) {
              model.advancedScores[s.key] = score.toDouble();

              int count = 0;
              double avg = 0;
              for (final v in model.advancedScores.values)
                if (v > 0) {
                  avg += v;
                  count++;
                }

              if (count > 0) avg /= count;

              if (model.score != avg) {
                model.score = avg;
                entry.update([EntryController.SCORE_ID]);
              }
            },
          ),
        ));

      advancedScoring.add(_FieldGrid(fields, minWidth: 140));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: CustomScrollView(
        physics: Config.PHYSICS,
        slivers: [
          const SliverToBoxAdapter(child: SizedBox(height: 10)),
          _FieldGrid([
            GetBuilder<EntryController>(
              id: EntryController.STATUS_ID,
              tag: model.mediaId.toString(),
              builder: (_) => DropDownField<ListStatus?>(
                hint: 'Add',
                title: 'Status',
                value: model.status,
                items: Map.fromIterable(
                  ListStatus.values,
                  key: (v) => listStatusSpecification(
                    v,
                    model.type == 'ANIME',
                  ),
                  value: (v) => v,
                ),
                onChanged: (status) {
                  model.status = status;

                  if (old.status == null &&
                      model.status == ListStatus.CURRENT &&
                      model.startedAt == null) {
                    model.startedAt = DateTime.now();
                    entry.update([EntryController.START_DATE_ID]);
                    Toast.show(context, 'Start date changed');
                    return;
                  }

                  if (old.status != model.status &&
                      model.status == ListStatus.COMPLETED &&
                      model.completedAt == null) {
                    model.completedAt = DateTime.now();
                    entry.update([EntryController.COMPLETE_DATE_ID]);
                    String text = 'Completed date changed';

                    if (model.progressMax != null &&
                        model.progress < model.progressMax!) {
                      model.progress = model.progressMax!;
                      entry.update([EntryController.PROGRESS_ID]);
                      text = 'Completed date & progress changed';
                    }

                    Toast.show(context, text);
                  }
                },
              ),
            ),
            InputFieldStructure(
              title: 'Progress',
              child: GetBuilder<EntryController>(
                id: EntryController.PROGRESS_ID,
                tag: model.mediaId.toString(),
                builder: (_) => NumberField(
                  value: model.progress,
                  maxValue: model.progressMax ?? 100000,
                  update: (progress) {
                    model.progress = progress.toInt();

                    if (model.progressMax != null &&
                        model.progress == model.progressMax &&
                        old.progress != model.progress) {
                      String? text;

                      if (old.status == model.status &&
                          old.status != ListStatus.COMPLETED) {
                        model.status = ListStatus.COMPLETED;
                        entry.update([EntryController.STATUS_ID]);
                        text = 'Status changed';
                      }

                      if (old.completedAt == model.completedAt &&
                          old.completedAt == null) {
                        model.completedAt = DateTime.now();
                        entry.update([EntryController.COMPLETE_DATE_ID]);
                        text = text == null
                            ? 'Completed date changed'
                            : 'Status & Completed date changed';
                      }

                      if (text != null) Toast.show(context, text);
                      return;
                    }

                    if (old.progress == 0 && old.progress != model.progress) {
                      String? text;

                      if (old.status == model.status &&
                          (old.status == null ||
                              old.status == ListStatus.PLANNING)) {
                        model.status = ListStatus.CURRENT;
                        entry.update([EntryController.STATUS_ID]);
                        text = 'Status changed';
                      }

                      if (old.startedAt == null && model.startedAt == null) {
                        model.startedAt = DateTime.now();
                        entry.update([EntryController.START_DATE_ID]);
                        text = text == null
                            ? 'Start date changed'
                            : 'Status & start date changed';
                      }

                      if (text != null) Toast.show(context, text);
                    }
                  },
                ),
              ),
            ),
            InputFieldStructure(
              title: 'Repeat',
              child: NumberField(
                value: model.repeat,
                update: (repeat) => model.repeat = repeat.toInt(),
              ),
            ),
            if (model.type != 'ANIME')
              InputFieldStructure(
                title: 'Progress Volumes',
                child: NumberField(
                  value: model.progressVolumes,
                  maxValue: model.progressVolumesMax ?? 100000,
                  update: (progressVolumes) =>
                      model.progressVolumes = progressVolumes.toInt(),
                ),
              ),
          ], minWidth: 140),
          const SliverToBoxAdapter(child: SizedBox(height: 10)),
          SliverToBoxAdapter(
            child: InputFieldStructure(
              title: 'Score',
              child: GetBuilder<EntryController>(
                id: EntryController.SCORE_ID,
                tag: model.mediaId.toString(),
                builder: (_) => ScorePicker(model),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 10)),
          SliverToBoxAdapter(
            child: InputFieldStructure(
              title: 'Notes',
              child: ExpandableField(
                text: model.notes,
                onChanged: (notes) => model.notes = notes,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 10)),
          _FieldGrid([
            InputFieldStructure(
              title: 'Started',
              child: GetBuilder<EntryController>(
                id: EntryController.START_DATE_ID,
                tag: model.mediaId.toString(),
                builder: (_) => DateField(
                  date: model.startedAt,
                  onChanged: (startDate) {
                    model.startedAt = startDate;

                    if (startDate == null) return;

                    if (old.status == null && model.status == null) {
                      model.status = ListStatus.CURRENT;
                      entry.update([EntryController.STATUS_ID]);
                      Toast.show(context, 'Status changed');
                    }
                  },
                  helpText: 'Started',
                ),
              ),
            ),
            InputFieldStructure(
              title: 'Completed',
              child: GetBuilder<EntryController>(
                id: EntryController.COMPLETE_DATE_ID,
                tag: model.mediaId.toString(),
                builder: (_) => DateField(
                  date: model.completedAt,
                  onChanged: (endDate) {
                    model.completedAt = endDate;

                    if (endDate == null) return;

                    if (old.status != ListStatus.COMPLETED &&
                        old.status != ListStatus.REPEATING &&
                        old.status == model.status) {
                      model.status = ListStatus.COMPLETED;
                      entry.update([EntryController.STATUS_ID]);
                      String text = 'Status changed';

                      if (model.progressMax != null &&
                          model.progress < model.progressMax!) {
                        model.progress = model.progressMax!;
                        entry.update([EntryController.PROGRESS_ID]);
                        text = 'Status & progress changed';
                      }

                      Toast.show(context, text);
                    }
                  },
                  helpText: 'Completed',
                ),
              ),
            ),
          ], minWidth: 165),
          ...advancedScoring,
          const SliverToBoxAdapter(child: SizedBox(height: 10)),
          _Label('Additional Settings'),
          _CheckboxGrid(
            {
              'Private': model.private,
              'Hidden From Status Lists': model.hiddenFromStatusLists,
            },
            (key, val) => key == 'Private'
                ? model.private = val
                : model.hiddenFromStatusLists = val,
          ),
          if (model.customLists.isNotEmpty) ...[
            const SliverToBoxAdapter(child: SizedBox(height: 10)),
            _Label('Custom Lists'),
            _CheckboxGrid(
              model.customLists,
              (key, val) => model.customLists[key] = val,
            ),
          ],
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String label;

  _Label(this.label);

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Text(label, style: Theme.of(context).textTheme.subtitle1),
    );
  }
}

class _FieldGrid extends StatelessWidget {
  final List<Widget> list;
  final double minWidth;

  _FieldGrid(this.list, {required this.minWidth});

  @override
  Widget build(BuildContext context) {
    return SliverGrid(
      delegate: SliverChildListDelegate.fixed(list),
      gridDelegate: SliverGridDelegateWithMinWidthAndFixedHeight(
        minWidth: minWidth,
        height: 71,
      ),
    );
  }
}

class _CheckboxGrid extends StatelessWidget {
  final Map<String, bool> map;
  final Function(String, bool) onChanged;

  _CheckboxGrid(this.map, this.onChanged);

  @override
  Widget build(BuildContext context) {
    if (map.isEmpty) return const SliverToBoxAdapter();

    return SliverGrid(
      delegate: SliverChildBuilderDelegate(
        (_, index) => CheckboxField(
          title: map.entries.elementAt(index).key,
          initialValue: map.entries.elementAt(index).value,
          onChanged: (val) => onChanged(map.entries.elementAt(index).key, val),
        ),
        childCount: map.length,
      ),
      gridDelegate: const SliverGridDelegateWithMinWidthAndFixedHeight(
        minWidth: 190,
        height: Config.MATERIAL_TAP_TARGET_SIZE,
        mainAxisSpacing: 0,
      ),
    );
  }
}
