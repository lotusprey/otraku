import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/controllers/collection_controller.dart';
import 'package:otraku/controllers/edit_controller.dart';
import 'package:otraku/controllers/home_controller.dart';
import 'package:otraku/constants/list_status.dart';
import 'package:otraku/constants/score_format.dart';
import 'package:otraku/models/edit_model.dart';
import 'package:otraku/constants/consts.dart';
import 'package:otraku/utils/convert.dart';
import 'package:otraku/utils/settings.dart';
import 'package:otraku/widgets/fields/checkbox_field.dart';
import 'package:otraku/widgets/fields/date_field.dart';
import 'package:otraku/widgets/fields/drop_down_field.dart';
import 'package:otraku/widgets/fields/expandable_field.dart';
import 'package:otraku/widgets/layouts/sliver_grid_delegates.dart';
import 'package:otraku/widgets/loaders.dart/loader.dart';
import 'package:otraku/widgets/fields/input_field_structure.dart';
import 'package:otraku/widgets/fields/number_field.dart';
import 'package:otraku/widgets/fields/score_picker.dart';
import 'package:otraku/widgets/overlays/dialogs.dart';
import 'package:otraku/widgets/overlays/sheets.dart';
import 'package:otraku/widgets/overlays/toast.dart';

/// A sheet for entry editing. Should be opened with [showSheet].
class EditView extends StatelessWidget {
  EditView(
    this.mediaId, {
    this.model,
    this.callback,
    this.complete = false,
  });

  final int mediaId;
  final EditModel? model;
  final void Function(EditModel)? callback;
  final bool complete;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<EditController>(
      id: EditController.ID_MAIN,
      tag: mediaId.toString(),
      init: EditController(mediaId, model, complete),
      builder: (ctrl) {
        final buttons = <Widget>[];
        if (ctrl.model != null) {
          if (ctrl.oldModel?.status != null)
            buttons.add(OpaqueSheetViewButton(
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
                      tag: ctrl.model!.type == 'ANIME'
                          ? '${Settings().id}true'
                          : '${Settings().id}false',
                    ).removeEntry(ctrl.oldModel!);
                    callback?.call(EditModel.emptyCopy(ctrl.model!));
                    Navigator.pop(context);
                  },
                ),
              ),
            ));
          else
            buttons.add(const Spacer());

          buttons.add(_SaveButton(ctrl, callback));
        }

        return OpaqueSheetView(
          buttons: buttons,
          builder: (context, scrollCtrl) => ctrl.model != null
              ? _EditView(ctrl, scrollCtrl)
              : const Center(child: Loader()),
        );
      },
    );
  }
}

class _SaveButton extends StatefulWidget {
  _SaveButton(this.ctrl, this.callback);

  final EditController ctrl;
  final void Function(EditModel)? callback;

  @override
  __SaveButtonState createState() => __SaveButtonState();
}

class __SaveButtonState extends State<_SaveButton> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Expanded(child: Center(child: Loader()));

    return OpaqueSheetViewButton(
      text: 'Save',
      icon: Ionicons.save_outline,
      onTap: () {
        setState(() => _loading = true);
        Get.find<CollectionController>(
          tag: widget.ctrl.model!.type == 'ANIME'
              ? '${Settings().id}true'
              : '${Settings().id}false',
        ).updateEntry(widget.ctrl.oldModel!, widget.ctrl.model!).then((_) {
          widget.callback?.call(widget.ctrl.model!);
          Navigator.pop(context);
        });
      },
    );
  }
}

class _EditView extends StatelessWidget {
  _EditView(this.ctrl, this.scrollCtrl);

  final EditController ctrl;
  final ScrollController scrollCtrl;

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<HomeController>().siteSettings!;
    final old = ctrl.oldModel!;
    final model = ctrl.model!;

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
                ctrl.update([EditController.ID_SCORE]);
              }
            },
          ),
        ));

      advancedScoring.add(_FieldGrid(fields, minWidth: 140));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: CustomScrollView(
        controller: scrollCtrl,
        physics: Consts.PHYSICS,
        slivers: [
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
          _FieldGrid([
            GetBuilder<EditController>(
              id: EditController.ID_STATUS,
              tag: model.mediaId.toString(),
              builder: (_) => DropDownField<ListStatus?>(
                hint: 'Add',
                title: 'Status',
                value: model.status,
                items: Map.fromIterable(
                  ListStatus.values,
                  key: (v) => Convert.adaptListStatus(v, model.type == 'ANIME'),
                ),
                onChanged: (status) {
                  model.status = status;

                  if (old.status == null &&
                      model.status == ListStatus.CURRENT &&
                      model.startedAt == null) {
                    model.startedAt = DateTime.now();
                    ctrl.update([EditController.ID_START_DATE]);
                    Toast.show(context, 'Start date changed');
                    return;
                  }

                  if (old.status != model.status &&
                      model.status == ListStatus.COMPLETED &&
                      model.completedAt == null) {
                    model.completedAt = DateTime.now();
                    ctrl.update([EditController.ID_COMPLETE_DATE]);
                    String text = 'Completed date changed';

                    if (model.progressMax != null &&
                        model.progress < model.progressMax!) {
                      model.progress = model.progressMax!;
                      ctrl.update([EditController.ID_PROGRESS]);
                      text = 'Completed date & progress changed';
                    }

                    Toast.show(context, text);
                  }
                },
              ),
            ),
            InputFieldStructure(
              title: 'Progress',
              child: GetBuilder<EditController>(
                id: EditController.ID_PROGRESS,
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
                        ctrl.update([EditController.ID_STATUS]);
                        text = 'Status changed';
                      }

                      if (old.completedAt == model.completedAt &&
                          old.completedAt == null) {
                        model.completedAt = DateTime.now();
                        ctrl.update([EditController.ID_COMPLETE_DATE]);
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
                        ctrl.update([EditController.ID_STATUS]);
                        text = 'Status changed';
                      }

                      if (old.startedAt == null && model.startedAt == null) {
                        model.startedAt = DateTime.now();
                        ctrl.update([EditController.ID_START_DATE]);
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
              child: GetBuilder<EditController>(
                id: EditController.ID_SCORE,
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
              child: GetBuilder<EditController>(
                id: EditController.ID_START_DATE,
                tag: model.mediaId.toString(),
                builder: (_) => DateField(
                  date: model.startedAt,
                  onChanged: (startDate) {
                    model.startedAt = startDate;

                    if (startDate == null) return;

                    if (old.status == null && model.status == null) {
                      model.status = ListStatus.CURRENT;
                      ctrl.update([EditController.ID_STATUS]);
                      Toast.show(context, 'Status changed');
                    }
                  },
                ),
              ),
            ),
            InputFieldStructure(
              title: 'Completed',
              child: GetBuilder<EditController>(
                id: EditController.ID_COMPLETE_DATE,
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
                      ctrl.update([EditController.ID_STATUS]);
                      String text = 'Status changed';

                      if (model.progressMax != null &&
                          model.progress < model.progressMax!) {
                        model.progress = model.progressMax!;
                        ctrl.update([EditController.ID_PROGRESS]);
                        text = 'Status & progress changed';
                      }

                      Toast.show(context, text);
                    }
                  },
                ),
              ),
            ),
          ], minWidth: 165),
          ...advancedScoring,
          const SliverToBoxAdapter(child: SizedBox(height: 10)),
          const _Label('Additional Settings'),
          _CheckBoxGrid(
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
            const _Label('Custom Lists'),
            _CheckBoxGrid(
              model.customLists,
              (key, val) => model.customLists[key] = val,
            ),
          ],
          const SliverToBoxAdapter(child: SizedBox(height: 60)),
        ],
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
  _FieldGrid(this.list, {required this.minWidth});

  final List<Widget> list;
  final double minWidth;

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
        height: Consts.MATERIAL_TAP_TARGET_SIZE,
      ),
    );
  }
}
