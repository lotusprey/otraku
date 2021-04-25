import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otraku/controllers/collection.dart';
import 'package:otraku/controllers/entry.dart';
import 'package:otraku/controllers/viewer.dart';
import 'package:otraku/enums/list_status.dart';
import 'package:otraku/enums/score_format.dart';
import 'package:otraku/models/entry_model.dart';
import 'package:otraku/models/settings_model.dart';
import 'package:otraku/utils/config.dart';
import 'package:otraku/widgets/action_icon.dart';
import 'package:otraku/widgets/fields/checkbox_field.dart';
import 'package:otraku/widgets/fields/date_field.dart';
import 'package:otraku/widgets/fields/drop_down_field.dart';
import 'package:otraku/widgets/fields/expandable_field.dart';
import 'package:otraku/widgets/layouts/sliver_grid_delegates.dart';
import 'package:otraku/widgets/navigation/custom_app_bar.dart';
import 'package:otraku/widgets/fields/input_field_structure.dart';
import 'package:otraku/widgets/fields/number_field.dart';
import 'package:otraku/widgets/fields/score_picker.dart';
import 'package:otraku/widgets/overlays/dialogs.dart';

class EntryPage extends StatefulWidget {
  static const ROUTE = '/edit';

  final int mediaId;
  final Function(ListStatus?)? callback;

  EntryPage(this.mediaId, this.callback);

  @override
  _EntryPageState createState() => _EntryPageState();
}

class _EntryPageState extends State<EntryPage> {
  @override
  Widget build(BuildContext context) => GetBuilder<Entry>(builder: (entry) {
        final model = entry.model;

        return Scaffold(
          appBar: CustomAppBar(
            title: 'Edit',
            trailing: model != null
                ? [
                    if (model.entryId != null)
                      ActionIcon(
                        dimmed: false,
                        tooltip: 'Remove',
                        icon: FluentIcons.delete_24_filled,
                        onPressed: () => showPopUp(
                          context,
                          AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: Config.BORDER_RADIUS,
                            ),
                            backgroundColor: Theme.of(context).primaryColor,
                            title: Text(
                              'Remove entry?',
                              style: Theme.of(context).textTheme.bodyText1,
                            ),
                            actions: [
                              TextButton(
                                child: Text(
                                  'No',
                                  style: TextStyle(
                                    color: Theme.of(context).dividerColor,
                                  ),
                                ),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                              TextButton(
                                child: Text('Yes'),
                                onPressed: () {
                                  Get.find<Collection>(
                                    tag: model.type == 'ANIME'
                                        ? Collection.ANIME
                                        : Collection.MANGA,
                                  ).removeEntry(entry.oldModel!);
                                  Navigator.of(context).pop();
                                  Navigator.of(context).pop();
                                  widget.callback?.call(null);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ActionIcon(
                        dimmed: false,
                        tooltip: 'Save',
                        icon: FluentIcons.save_24_filled,
                        onPressed: () {
                          if (entry.oldModel!.status == null &&
                              entry.model!.status == ListStatus.CURRENT &&
                              entry.model!.startedAt == null)
                            entry.model!.startedAt = DateTime.now();

                          if (entry.oldModel!.status != ListStatus.COMPLETED &&
                              entry.model!.status == ListStatus.COMPLETED &&
                              entry.model!.completedAt == null)
                            entry.model!.completedAt = DateTime.now();

                          Get.find<Collection>(
                            tag: model.type == 'ANIME'
                                ? Collection.ANIME
                                : Collection.MANGA,
                          ).updateEntry(entry.oldModel!, model);
                          Navigator.of(context).pop();
                          widget.callback?.call(model.status);
                        }),
                  ]
                : [],
          ),
          body: model != null
              ? _Content(model, Get.find<Viewer>().settings!)
              : const SizedBox(),
        );
      });
}

class _Content extends StatelessWidget {
  final EntryModel model;
  final SettingsModel settings;
  _Content(this.model, this.settings);

  @override
  Widget build(BuildContext context) {
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
            initialValue: s.value,
            maxValue: 10,
            update: (score) => model.advancedScores[s.key] = score.toDouble(),
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
            DropDownField<ListStatus>(
              hint: 'Add',
              title: 'Status',
              initialValue: model.status,
              items: Map.fromIterable(
                ListStatus.values,
                key: (v) => listStatusSpecification(
                  v,
                  model.type == 'ANIME',
                ),
                value: (v) => v,
              ),
              onChanged: (status) => model.status = status,
            ),
            InputFieldStructure(
              title: 'Progress',
              child: NumberField(
                initialValue: model.progress,
                maxValue: model.progressMax ?? 100000,
                update: (progress) => model.progress = progress.toInt(),
              ),
            ),
            InputFieldStructure(
              title: 'Repeat',
              child: NumberField(
                initialValue: model.repeat,
                update: (repeat) => model.repeat = repeat.toInt(),
              ),
            ),
            if (model.type != 'ANIME')
              InputFieldStructure(
                title: 'Progress Volumes',
                child: NumberField(
                  initialValue: model.progressVolumes,
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
              child: ScorePicker(model),
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
              title: 'Start Date',
              child: DateField(
                date: model.startedAt,
                onChanged: (startDate) => model.startedAt = startDate,
                helpText: 'Start Date',
              ),
            ),
            InputFieldStructure(
              title: 'End Date',
              child: DateField(
                date: model.completedAt,
                onChanged: (endDate) => model.completedAt = endDate,
                helpText: 'End Date',
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
