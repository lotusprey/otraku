import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otraku/controllers/entry.dart';
import 'package:otraku/enums/media_list_status_enum.dart';
import 'package:otraku/models/page_data/edit_entry.dart';
import 'package:otraku/controllers/collections.dart';
import 'package:otraku/controllers/config.dart';
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
  final _box = const SizedBox(width: 10, height: 10);

  EditEntry _oldData;
  EditEntry _newData;

  Widget _row(Widget child1, Widget child2) {
    return Row(
      children: [
        Expanded(child: child1),
        _box,
        Expanded(child: child2 ?? const SizedBox(height: 75)),
      ],
    );
  }

  List<Widget> _rows() {
    List<Widget> list = [];
    for (int i = 1; i < _newData.customLists.length; i += 2) {
      list.add(_row(
        CheckboxField(
          title: _newData.customLists[i - 1].item1,
          initialValue: _newData.customLists[i - 1].item2,
          onChanged: (boolean) => _newData.customLists[i - 1] =
              _newData.customLists[i - 1].withItem2(boolean),
        ),
        CheckboxField(
          title: _newData.customLists[i].item1,
          initialValue: _newData.customLists[i].item2,
          onChanged: (boolean) => _newData.customLists[i] =
              _newData.customLists[i].withItem2(boolean),
        ),
      ));
    }
    if (_newData.customLists.length % 2 != 0) {
      list.add(_row(
        CheckboxField(
          title: _newData.customLists.last.item1,
          initialValue: _newData.customLists.last.item2,
          onChanged: (boolean) => _newData.customLists.last =
              _newData.customLists.last.withItem2(boolean),
        ),
        null,
      ));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: CustomAppBar(
          title: 'Edit',
          trailing: [
            if (_oldData != null) ...[
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
                            Get.find<Collections>().removeEntry(_oldData);
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
                    Get.find<Collections>().updateEntry(_oldData, _newData);
                    Navigator.of(context).pop();
                    widget.update(_newData.status);
                  }),
            ],
          ],
        ),
        body: _oldData != null
            ? LayoutBuilder(
                builder: (_, constraints) => ListView(
                  physics: Config.PHYSICS,
                  padding: Config.PADDING,
                  children: [
                    _row(
                      DropDownField(
                        hint: 'Add',
                        title: 'Status',
                        initialValue: _newData.status,
                        items: Map.fromIterable(
                          MediaListStatus.values,
                          key: (v) => listStatusSpecification(
                              v, _newData.type == 'ANIME'),
                          value: (v) => v,
                        ),
                        onChanged: (status) => _newData.status = status,
                      ),
                      InputFieldStructure(
                        title: 'Progress',
                        body: NumberField(
                          initialValue: _newData.progress,
                          maxValue: _newData.progressMax ?? 100000,
                          update: (progress) => _newData.progress = progress,
                        ),
                      ),
                    ),
                    _row(
                      InputFieldStructure(
                        title: 'Repeat',
                        body: NumberField(
                          initialValue: _newData.repeat,
                          update: (repeat) => _newData.repeat = repeat,
                        ),
                      ),
                      _oldData.type == 'MANGA'
                          ? InputFieldStructure(
                              title: 'Progress Volumes',
                              body: NumberField(
                                initialValue: _newData.progressVolumes,
                                maxValue: _newData.progressVolumesMax ?? 100000,
                                update: (progressVolumes) =>
                                    _newData.progressVolumes = progressVolumes,
                              ),
                            )
                          : null,
                    ),
                    InputFieldStructure(
                      title: 'Score',
                      body: ScorePicker(_newData),
                    ),
                    InputFieldStructure(
                      title: 'Notes',
                      body: ExpandableField(
                        text: _newData.notes,
                        onChanged: (notes) => _newData.notes = notes,
                      ),
                      enforceHeight: false,
                    ),
                    if (constraints.maxWidth < 380) ...[
                      InputFieldStructure(
                        title: 'Start Date',
                        body: DateField(
                          date: _newData.startedAt,
                          onChanged: (startDate) =>
                              _newData.startedAt = startDate,
                          helpText: 'Start Date',
                        ),
                      ),
                      InputFieldStructure(
                        title: 'End Date',
                        body: DateField(
                          date: _newData.completedAt,
                          onChanged: (endDate) =>
                              _newData.completedAt = endDate,
                          helpText: 'End Date',
                        ),
                      ),
                    ] else
                      _row(
                        InputFieldStructure(
                          title: 'Start Date',
                          body: DateField(
                            date: _newData.startedAt,
                            onChanged: (startDate) =>
                                _newData.startedAt = startDate,
                            helpText: 'Start Date',
                          ),
                        ),
                        InputFieldStructure(
                          title: 'End Date',
                          body: DateField(
                            date: _newData.completedAt,
                            onChanged: (endDate) =>
                                _newData.completedAt = endDate,
                            helpText: 'End Date',
                          ),
                        ),
                      ),
                    InputFieldStructure(
                      title: 'Additional List Settings',
                      body: _row(
                        CheckboxField(
                          title: 'Private',
                          initialValue: _newData.private,
                          onChanged: (private) => _newData.private = private,
                        ),
                        CheckboxField(
                          title: 'Hide from status lists',
                          initialValue: _newData.hiddenFromStatusLists,
                          onChanged: (hiddenFromStatusLists) => _newData
                              .hiddenFromStatusLists = hiddenFromStatusLists,
                        ),
                      ),
                    ),
                    if (_oldData.customLists.length > 0)
                      InputFieldStructure(
                        enforceHeight: false,
                        title: 'Custom Lists',
                        body: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: _rows(),
                        ),
                      ),
                  ],
                ),
              )
            : _box,
      );

  @override
  void initState() {
    super.initState();
    Entry.fetchUserData(widget.mediaId).then((entry) {
      if (entry == null) return;
      if (mounted) {
        setState(() {
          _oldData = entry;
          _newData = _oldData.clone();
        });
      }
    });
  }
}
