import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otraku/controllers/collection.dart';
import 'package:otraku/controllers/entry.dart';
import 'package:otraku/enums/list_status.dart';
import 'package:otraku/controllers/config.dart';
import 'package:otraku/tools/fields/checkbox_field.dart';
import 'package:otraku/tools/fields/date_field.dart';
import 'package:otraku/tools/fields/drop_down_field.dart';
import 'package:otraku/tools/fields/expandable_field.dart';
import 'package:otraku/tools/layouts/custom_grid_delegate.dart';
import 'package:otraku/tools/navigation/custom_app_bar.dart';
import 'package:otraku/tools/fields/input_field_structure.dart';
import 'package:otraku/tools/fields/number_field.dart';
import 'package:otraku/tools/fields/score_picker.dart';
import 'package:otraku/tools/overlays/dialogs.dart';

class EditEntryPage extends StatefulWidget {
  final int mediaId;
  final Function(ListStatus) update;

  EditEntryPage(this.mediaId, this.update);

  @override
  _EditEntryPageState createState() => _EditEntryPageState();
}

class _EditEntryPageState extends State<EditEntryPage> {
  @override
  Widget build(BuildContext context) => GetBuilder<Entry>(builder: (entry) {
        final data = entry.data;
        return Scaffold(
          appBar: CustomAppBar(
            title: 'Edit',
            trailing: [
              if (data != null) ...[
                if (data.entryId != null)
                  IconButton(
                    icon: const Icon(FluentSystemIcons.ic_fluent_delete_filled),
                    color: Theme.of(context).dividerColor,
                    onPressed: () => showDialog(
                      context: context,
                      builder: (_) => PopUpAnimation(
                        AlertDialog(
                          backgroundColor: Theme.of(context).primaryColor,
                          title: Text(
                            'Remove entry?',
                            style: Theme.of(context).textTheme.bodyText1,
                          ),
                          actions: [
                            FlatButton(
                              child: Text(
                                'No',
                                style: Theme.of(context).textTheme.bodyText1,
                              ),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                            FlatButton(
                              child: Text(
                                'Yes',
                                style: Theme.of(context).textTheme.bodyText2,
                              ),
                              onPressed: () {
                                Get.find<Collection>(
                                  tag: data.type == 'ANIME'
                                      ? Collection.ANIME
                                      : Collection.MANGA,
                                ).removeEntry(entry.oldData);
                                Navigator.of(context).pop();
                                Navigator.of(context).pop();
                                widget.update(null);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                IconButton(
                    icon: const Icon(FluentSystemIcons.ic_fluent_save_filled),
                    color: Theme.of(context).dividerColor,
                    onPressed: () {
                      Get.find<Collection>(
                        tag: data.type == 'ANIME'
                            ? Collection.ANIME
                            : Collection.MANGA,
                      ).updateEntry(entry.oldData, data);
                      Navigator.of(context).pop();
                      widget.update(data.status);
                    }),
              ],
            ],
          ),
          body: data != null
              ? Padding(
                  padding: Config.PADDING,
                  child: CustomScrollView(
                    physics: Config.PHYSICS,
                    slivers: [
                      _FieldGrid([
                        DropDownField(
                          hint: 'Add',
                          title: 'Status',
                          initialValue: data.status,
                          items: Map.fromIterable(
                            ListStatus.values,
                            key: (v) => listStatusSpecification(
                                v, data.type == 'ANIME'),
                            value: (v) => v,
                          ),
                          onChanged: (status) => data.status = status,
                        ),
                        InputFieldStructure(
                          title: 'Progress',
                          child: NumberField(
                            initialValue: data.progress,
                            maxValue: data.progressMax ?? 100000,
                            update: (progress) => data.progress = progress,
                          ),
                        ),
                        InputFieldStructure(
                          title: 'Repeat',
                          child: NumberField(
                            initialValue: data.repeat,
                            update: (repeat) => data.repeat = repeat,
                          ),
                        ),
                        if (data.type != 'ANIME')
                          InputFieldStructure(
                            title: 'Progress Volumes',
                            child: NumberField(
                              initialValue: data.progressVolumes,
                              maxValue: data.progressVolumesMax ?? 100000,
                              update: (progressVolumes) =>
                                  data.progressVolumes = progressVolumes,
                            ),
                          ),
                      ], minWidth: 140),
                      const SliverToBoxAdapter(child: SizedBox(height: 10)),
                      SliverToBoxAdapter(
                        child: InputFieldStructure(
                          title: 'Score',
                          child: ScorePicker(data),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: InputFieldStructure(
                          title: 'Notes',
                          child: ExpandableField(
                            text: data.notes,
                            onChanged: (notes) => data.notes = notes,
                          ),
                        ),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 10)),
                      _FieldGrid([
                        InputFieldStructure(
                          title: 'Start Date',
                          child: DateField(
                            date: data.startedAt,
                            onChanged: (startDate) =>
                                data.startedAt = startDate,
                            helpText: 'Start Date',
                          ),
                        ),
                        InputFieldStructure(
                          title: 'End Date',
                          child: DateField(
                            date: data.completedAt,
                            onChanged: (endDate) => data.completedAt = endDate,
                            helpText: 'End Date',
                          ),
                        ),
                      ], minWidth: 165),
                      const SliverToBoxAdapter(child: SizedBox(height: 10)),
                      _Label('Additional Settings'),
                      _CheckboxGrid(
                        {
                          'Private': data.private,
                          'Hidden From Status Lists':
                              data.hiddenFromStatusLists,
                        },
                        (key, val) => key == 'Private'
                            ? data.private = val
                            : data.hiddenFromStatusLists = val,
                      ),
                      if (data.customLists.isNotEmpty) ...[
                        const SliverToBoxAdapter(child: SizedBox(height: 10)),
                        _Label('Custom Lists'),
                        _CheckboxGrid(
                          data.customLists,
                          (key, val) => data.customLists[key] = val,
                        ),
                      ],
                    ],
                  ),
                )
              : const SizedBox(),
        );
      });
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

  _FieldGrid(this.list, {@required this.minWidth});

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
