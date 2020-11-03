import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:otraku/enums/media_list_status_enum.dart';
import 'package:otraku/models/page_data/edit_entry.dart';
import 'package:otraku/providers/collections.dart';
import 'package:otraku/providers/media_item.dart';
import 'package:otraku/providers/app_config.dart';
import 'package:otraku/tools/blossom_loader.dart';
import 'package:otraku/tools/fields/checkbox_field.dart';
import 'package:otraku/tools/fields/date_field.dart';
import 'package:otraku/tools/fields/expandable_field.dart';
import 'package:otraku/tools/headers/custom_app_bar.dart';
import 'package:otraku/tools/fields/input_field_structure.dart';
import 'package:otraku/tools/fields/number_field.dart';
import 'package:otraku/tools/fields/score_picker.dart';
import 'package:provider/provider.dart';

class EditEntryPage extends StatefulWidget {
  final int mediaId;
  final Function(MediaListStatus) update;

  EditEntryPage(this.mediaId, this.update);

  @override
  _EditEntryPageState createState() => _EditEntryPageState();
}

class _EditEntryPageState extends State<EditEntryPage> {
  static const _box = SizedBox(width: 10, height: 10);

  EditEntry _oldData;
  EditEntry _newData;
  String _scoreFormat;

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
          text: _newData.customLists[i - 1].item1,
          initialValue: _newData.customLists[i - 1].item2,
          onChanged: (boolean) => _newData.customLists[i - 1] =
              _newData.customLists[i - 1].withItem2(boolean),
        ),
        CheckboxField(
          text: _newData.customLists[i].item1,
          initialValue: _newData.customLists[i].item2,
          onChanged: (boolean) => _newData.customLists[i] =
              _newData.customLists[i].withItem2(boolean),
        ),
      ));
    }
    if (_newData.customLists.length % 2 != 0) {
      list.add(_row(
        CheckboxField(
          text: _newData.customLists.last.item1,
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Edit',
        trailing: [
          _UpdateButtons(
            original: _oldData,
            changed: _newData,
            // collection: _collection,
            update: widget.update,
          )
        ],
        wrapTrailing: false,
      ),
      body: _oldData != null
          ? LayoutBuilder(
              builder: (_, constraints) => ListView(
                physics: const BouncingScrollPhysics(),
                padding: AppConfig.PADDING,
                children: [
                  _row(
                    InputFieldStructure(
                        title: 'Status', body: _StatusDropdown(_newData)),
                    InputFieldStructure(
                      title: 'Progress',
                      body: NumberField(
                        initialValue: _newData.progress,
                        maxValue: _newData.progressMax ?? 100000,
                        update: (progress) => _newData.progress = progress,
                      ),
                    ),
                  ),
                  _box,
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
                  _box,
                  InputFieldStructure(
                    title: 'Score',
                    body: ScorePicker(_newData, _scoreFormat),
                  ),
                  _box,
                  InputFieldStructure(
                    title: 'Notes',
                    body: ExpandableField(
                      text: _newData.notes,
                      onChanged: (notes) => _newData.notes = notes,
                    ),
                    enforceHeight: false,
                  ),
                  _box,
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
                    _box,
                    InputFieldStructure(
                      title: 'End Date',
                      body: DateField(
                        date: _newData.completedAt,
                        onChanged: (endDate) => _newData.completedAt = endDate,
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
                  _box,
                  InputFieldStructure(
                    enforceHeight: false,
                    title: 'Additional List Settings',
                    body: _row(
                      CheckboxField(
                        text: 'Private',
                        initialValue: _newData.private,
                        onChanged: (private) => _newData.private = private,
                      ),
                      CheckboxField(
                        text: 'Hide from status lists',
                        initialValue: _newData.hiddenFromStatusLists,
                        onChanged: (hiddenFromStatusLists) => _newData
                            .hiddenFromStatusLists = hiddenFromStatusLists,
                      ),
                    ),
                  ),
                  _box,
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
  }

  @override
  void initState() {
    super.initState();
    MediaItem.fetchUserData(widget.mediaId).then((data) {
      if (data == null) return;
      if (mounted) {
        setState(() {
          _oldData = data.item1;
          _newData = _oldData.clone();
          _scoreFormat = data.item2;
        });
      }
    });
  }
}

class _UpdateButtons extends StatefulWidget {
  final EditEntry original;
  final EditEntry changed;
  final Function(MediaListStatus) update;

  _UpdateButtons({
    @required this.original,
    @required this.changed,
    @required this.update,
  });

  @override
  _UpdateButtonsState createState() => _UpdateButtonsState();
}

class _UpdateButtonsState extends State<_UpdateButtons> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return widget.original != null && !_isLoading
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppBarIcon(
                IconButton(
                  icon: const Icon(FluentSystemIcons.ic_fluent_delete_filled),
                  color: Theme.of(context).dividerColor,
                  onPressed: () => showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
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
                            setState(() => _isLoading = true);
                            Provider.of<Collections>(context, listen: false)
                                .removeEntry(widget.original)
                                .then((ok) {
                              if (ok) {
                                Navigator.of(context).pop();
                                widget.update(null);
                              }
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              AppBarIcon(
                IconButton(
                    icon: const Icon(FluentSystemIcons.ic_fluent_save_filled),
                    color: Theme.of(context).dividerColor,
                    onPressed: () {
                      setState(() => _isLoading = true);
                      Provider.of<Collections>(context, listen: false)
                          .updateEntry(widget.original, widget.changed)
                          .then((ok) {
                        if (ok) {
                          Navigator.of(context).pop();
                          widget.update(widget.changed.status);
                        }
                      });
                    }),
              ),
            ],
          )
        : const AppBarIcon(BlossomLoader(size: 30));
  }
}

class _StatusDropdown extends StatefulWidget {
  final EditEntry data;

  _StatusDropdown(this.data);

  @override
  _StatusDropdownState createState() => _StatusDropdownState();
}

class _StatusDropdownState extends State<_StatusDropdown> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: AppConfig.BORDER_RADIUS,
      ),
      child: DropdownButton(
        value: widget.data.status,
        items: MediaListStatus.values
            .map((v) => DropdownMenuItem(
                  value: v,
                  child: Text(
                    listStatusSpecification(v, widget.data.type == 'ANIME'),
                    style: v != widget.data.status
                        ? Theme.of(context).textTheme.bodyText1
                        : Theme.of(context).textTheme.bodyText2,
                  ),
                ))
            .toList(),
        onChanged: (status) => setState(() => widget.data.status = status),
        hint: Text('Add', style: Theme.of(context).textTheme.subtitle1),
        iconEnabledColor: Theme.of(context).disabledColor,
        dropdownColor: Theme.of(context).primaryColor,
        underline: const SizedBox(),
        isExpanded: true,
      ),
    );
  }
}
