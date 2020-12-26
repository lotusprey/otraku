import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otraku/controllers/collection.dart';
import 'package:otraku/controllers/entry.dart';
import 'package:otraku/enums/media_list_status_enum.dart';
import 'package:otraku/services/config.dart';
import 'package:otraku/tools/fields/checkbox_field.dart';
import 'package:otraku/tools/fields/date_field.dart';
import 'package:otraku/tools/fields/drop_down_field.dart';
import 'package:otraku/tools/fields/expandable_field.dart';
import 'package:otraku/tools/navigators/custom_app_bar.dart';
import 'package:otraku/tools/fields/input_field_structure.dart';
import 'package:otraku/tools/fields/number_field.dart';
import 'package:otraku/tools/fields/score_picker.dart';
import 'package:otraku/tools/overlays/dialogs.dart';

class EditEntryPage extends StatefulWidget {
  final int mediaId;
  final Function(MediaListStatus) update;

  EditEntryPage(this.mediaId, this.update);

  @override
  _EditEntryPageState createState() => _EditEntryPageState();
}

class _EditEntryPageState extends State<EditEntryPage> {
  @override
  Widget build(BuildContext context) => GetBuilder<Entry>(
        builder: (entry) => Scaffold(
          appBar: CustomAppBar(
            title: 'Edit',
            trailing: [
              if (entry.data != null) ...[
                if (entry.data.entryId != null)
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
                                  tag: entry.data.type == 'ANIME'
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
                        tag: entry.data.type == 'ANIME'
                            ? Collection.ANIME
                            : Collection.MANGA,
                      ).updateEntry(entry.oldData, entry.data);
                      Navigator.of(context).pop();
                      widget.update(entry.data.status);
                    }),
              ],
            ],
          ),
          body: entry.data != null
              ? LayoutBuilder(
                  builder: (_, constraints) => ListView(
                    physics: Config.PHYSICS,
                    padding: Config.PADDING,
                    children: [
                      _Row(
                        DropDownField(
                          hint: 'Add',
                          title: 'Status',
                          initialValue: entry.data.status,
                          items: Map.fromIterable(
                            MediaListStatus.values,
                            key: (v) => listStatusSpecification(
                                v, entry.data.type == 'ANIME'),
                            value: (v) => v,
                          ),
                          onChanged: (status) => entry.data.status = status,
                        ),
                        InputFieldStructure(
                          title: 'Progress',
                          body: NumberField(
                            initialValue: entry.data.progress,
                            maxValue: entry.data.progressMax ?? 100000,
                            update: (progress) =>
                                entry.data.progress = progress,
                          ),
                        ),
                      ),
                      _Row(
                        InputFieldStructure(
                          title: 'Repeat',
                          body: NumberField(
                            initialValue: entry.data.repeat,
                            update: (repeat) => entry.data.repeat = repeat,
                          ),
                        ),
                        entry.data.type == 'MANGA'
                            ? InputFieldStructure(
                                title: 'Progress Volumes',
                                body: NumberField(
                                  initialValue: entry.data.progressVolumes,
                                  maxValue:
                                      entry.data.progressVolumesMax ?? 100000,
                                  update: (progressVolumes) => entry
                                      .data.progressVolumes = progressVolumes,
                                ),
                              )
                            : null,
                      ),
                      InputFieldStructure(
                        title: 'Score',
                        body: ScorePicker(entry.data),
                      ),
                      InputFieldStructure(
                        title: 'Notes',
                        body: ExpandableField(
                          text: entry.data.notes,
                          onChanged: (notes) => entry.data.notes = notes,
                        ),
                        enforceHeight: false,
                      ),
                      if (constraints.maxWidth < 380) ...[
                        InputFieldStructure(
                          title: 'Start Date',
                          body: DateField(
                            date: entry.data.startedAt,
                            onChanged: (startDate) =>
                                entry.data.startedAt = startDate,
                            helpText: 'Start Date',
                          ),
                        ),
                        InputFieldStructure(
                          title: 'End Date',
                          body: DateField(
                            date: entry.data.completedAt,
                            onChanged: (endDate) =>
                                entry.data.completedAt = endDate,
                            helpText: 'End Date',
                          ),
                        ),
                      ] else
                        _Row(
                          InputFieldStructure(
                            title: 'Start Date',
                            body: DateField(
                              date: entry.data.startedAt,
                              onChanged: (startDate) =>
                                  entry.data.startedAt = startDate,
                              helpText: 'Start Date',
                            ),
                          ),
                          InputFieldStructure(
                            title: 'End Date',
                            body: DateField(
                              date: entry.data.completedAt,
                              onChanged: (endDate) =>
                                  entry.data.completedAt = endDate,
                              helpText: 'End Date',
                            ),
                          ),
                        ),
                      InputFieldStructure(
                        title: 'Additional List Settings',
                        body: _Row(
                          CheckboxField(
                            title: 'Private',
                            initialValue: entry.data.private,
                            onChanged: (private) =>
                                entry.data.private = private,
                          ),
                          CheckboxField(
                            title: 'Hide from status lists',
                            initialValue: entry.data.hiddenFromStatusLists,
                            onChanged: (hiddenFromStatusLists) => entry.data
                                .hiddenFromStatusLists = hiddenFromStatusLists,
                          ),
                        ),
                      ),
                      if (entry.oldData.customLists.length > 0)
                        // TODO fix lists
                        InputFieldStructure(
                          enforceHeight: false,
                          title: 'Custom Lists',
                          body: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              for (int i = 1;
                                  i < entry.data.customLists.length;
                                  i += 2) ...[
                                _Row(
                                  CheckboxField(
                                    title: entry.data.customLists[i - 1].item1,
                                    initialValue:
                                        entry.data.customLists[i - 1].item2,
                                    onChanged: (boolean) =>
                                        entry.data.customLists[i - 1] = entry
                                            .data.customLists[i - 1]
                                            .withItem2(boolean),
                                  ),
                                  CheckboxField(
                                    title: entry.data.customLists[i].item1,
                                    initialValue:
                                        entry.data.customLists[i].item2,
                                    onChanged: (boolean) =>
                                        entry.data.customLists[i] = entry
                                            .data.customLists[i]
                                            .withItem2(boolean),
                                  ),
                                ),
                              ],
                              if (entry.data.customLists.length % 2 != 0)
                                _Row(
                                  CheckboxField(
                                    title: entry.data.customLists.last.item1,
                                    initialValue:
                                        entry.data.customLists.last.item2,
                                    onChanged: (boolean) =>
                                        entry.data.customLists.last = entry
                                            .data.customLists.last
                                            .withItem2(boolean),
                                  ),
                                  null,
                                ),
                            ],
                          ),
                        ),
                    ],
                  ),
                )
              : const SizedBox(width: 10, height: 10),
        ),
      );
}

class _Row extends StatelessWidget {
  final Widget child1;
  final Widget child2;

  _Row(this.child1, this.child2);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: child1),
        const SizedBox(width: 10, height: 10),
        Expanded(child: child2 ?? const SizedBox(height: 75)),
      ],
    );
  }
}
