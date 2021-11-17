import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/controllers/collection_controller.dart';
import 'package:otraku/controllers/entry_controller.dart';
import 'package:otraku/controllers/viewer_controller.dart';
import 'package:otraku/enums/list_status.dart';
import 'package:otraku/enums/score_format.dart';
import 'package:otraku/models/entry_model.dart';
import 'package:otraku/utils/config.dart';
import 'package:otraku/utils/convert.dart';
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
import 'package:otraku/widgets/overlays/toast.dart';

/// A [DraggableScrollableSheet] for entry editing
/// Should be opened with [DragSheet.show].
class EntryView extends StatelessWidget {
  EntryView(this.mediaId, [this.model, this.callback]);

  final int mediaId;
  final EntryModel? model;
  final void Function(EntryModel)? callback;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GetBuilder<EntryController>(
        id: EntryController.MAIN_ID,
        tag: mediaId.toString(),
        init: EntryController(mediaId, model),
        builder: (ctrl) {
          // This is cached to not rebuild each time the sheet is scrolled.
          Widget? editView;

          return DraggableScrollableSheet(
            expand: false,
            builder: (context, scrollCtrl) {
              if (editView == null)
                editView = Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.background,
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      child: ctrl.model != null
                          ? _EditView(ctrl, scrollCtrl)
                          : const Center(child: Loader()),
                    ),
                    if (ctrl.model != null) _Buttons(ctrl, callback),
                  ],
                );

              return editView!;
            },
          );
        },
      ),
    );
  }
}

class _Buttons extends StatefulWidget {
  _Buttons(this.ctrl, this.callback);

  final EntryController ctrl;
  final void Function(EntryModel)? callback;

  @override
  State<_Buttons> createState() => _ButtonsState();
}

class _ButtonsState extends State<_Buttons> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final ctrl = widget.ctrl;
    final remove = Expanded(
      child: ctrl.model!.status != null
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: ElevatedButton.icon(
                style: Theme.of(context).elevatedButtonTheme.style!.copyWith(
                      backgroundColor: MaterialStateProperty.all(
                        Theme.of(context).colorScheme.error,
                      ),
                    ),
                label: Text('Remove'),
                icon: Icon(Ionicons.trash_bin_outline),
                onPressed: () => showPopUp(
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
                      widget.callback?.call(EntryModel.emptyCopy(ctrl.model!));
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),
            )
          : const SizedBox(),
    );
    final save = Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: ElevatedButton.icon(
          label: Text('Save'),
          icon: Icon(Ionicons.save_outline),
          onPressed: () {
            setState(() => _loading = true);
            Get.find<CollectionController>(
              tag: ctrl.model!.type == 'ANIME'
                  ? CollectionController.ANIME
                  : CollectionController.MANGA,
            ).updateEntry(ctrl.oldModel!, ctrl.model!).then((_) {
              widget.callback?.call(ctrl.model!);
              Navigator.pop(context);
            });
          },
        ),
      ),
    );

    return Align(
      alignment: Alignment.bottomCenter,
      child: ClipRect(
        child: BackdropFilter(
          filter: Config.filter,
          child: Container(
            height: 50,
            width: double.infinity,
            color: Theme.of(context).cardColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children:
                  _loading ? const [Center(child: Loader())] : [remove, save],
            ),
          ),
        ),
      ),
    );
  }
}

class _EditView extends StatelessWidget {
  _EditView(this.ctrl, this.scrollCtrl);

  final EntryController ctrl;
  final ScrollController scrollCtrl;

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<ViewerController>().settings!;
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
                ctrl.update([EntryController.SCORE_ID]);
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
        physics: Config.PHYSICS,
        slivers: [
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
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
                  key: (v) => Convert.adaptListStatus(v, model.type == 'ANIME'),
                ),
                onChanged: (status) {
                  model.status = status;

                  if (old.status == null &&
                      model.status == ListStatus.CURRENT &&
                      model.startedAt == null) {
                    model.startedAt = DateTime.now();
                    ctrl.update([EntryController.START_DATE_ID]);
                    Toast.show(context, 'Start date changed');
                    return;
                  }

                  if (old.status != model.status &&
                      model.status == ListStatus.COMPLETED &&
                      model.completedAt == null) {
                    model.completedAt = DateTime.now();
                    ctrl.update([EntryController.COMPLETE_DATE_ID]);
                    String text = 'Completed date changed';

                    if (model.progressMax != null &&
                        model.progress < model.progressMax!) {
                      model.progress = model.progressMax!;
                      ctrl.update([EntryController.PROGRESS_ID]);
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
                        ctrl.update([EntryController.STATUS_ID]);
                        text = 'Status changed';
                      }

                      if (old.completedAt == model.completedAt &&
                          old.completedAt == null) {
                        model.completedAt = DateTime.now();
                        ctrl.update([EntryController.COMPLETE_DATE_ID]);
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
                        ctrl.update([EntryController.STATUS_ID]);
                        text = 'Status changed';
                      }

                      if (old.startedAt == null && model.startedAt == null) {
                        model.startedAt = DateTime.now();
                        ctrl.update([EntryController.START_DATE_ID]);
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
                      ctrl.update([EntryController.STATUS_ID]);
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
                      ctrl.update([EntryController.STATUS_ID]);
                      String text = 'Status changed';

                      if (model.progressMax != null &&
                          model.progress < model.progressMax!) {
                        model.progress = model.progressMax!;
                        ctrl.update([EntryController.PROGRESS_ID]);
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
            _Label('Custom Lists'),
            _CheckBoxGrid(
              model.customLists,
              (key, val) => model.customLists[key] = val,
            ),
          ],
          const SliverToBoxAdapter(child: SizedBox(height: 50)),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  _Label(this.label);

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
        height: Config.MATERIAL_TAP_TARGET_SIZE,
      ),
    );
  }
}
