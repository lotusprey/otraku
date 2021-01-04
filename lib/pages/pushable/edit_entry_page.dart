import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:otraku/controllers/collection.dart';
import 'package:otraku/controllers/entry.dart';
import 'package:otraku/enums/list_status.dart';
import 'package:otraku/models/tuple.dart';
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
                      ]),
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
                      ]),
                      const SliverToBoxAdapter(child: SizedBox(height: 10)),
                      _Label('Additional Settings'),
                      _CheckboxGrid(
                        [
                          Tuple('Private', data.private),
                          Tuple(
                            'Hidden From Status Lists',
                            data.hiddenFromStatusLists,
                          )
                        ],
                        (i, val) => i == 0
                            ? data.private = val
                            : data.hiddenFromStatusLists = val,
                      ),
                      if (data.customLists.isNotEmpty) ...[
                        const SliverToBoxAdapter(child: SizedBox(height: 10)),
                        _Label('Custom Lists'),
                        _CheckboxGrid(
                          data.customLists,
                          (i, val) => data.customLists[i].item2 = val,
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

  _FieldGrid(this.list);

  @override
  Widget build(BuildContext context) {
    final count =
        (MediaQuery.of(context).size.width - (list.length - 1) * 10 - 20) ~/
            170;
    return SliverGrid(
      delegate: SliverChildListDelegate.fixed(list),
      gridDelegate: _SliverGridDelegateWithFixedCrossAxisCountAndFixedHeight(
        crossAxisCount: count,
        height: 71,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
    );
  }
}

class _CheckboxGrid extends StatelessWidget {
  final List<Tuple<String, bool>> list;
  final Function(int, bool) onChanged;

  _CheckboxGrid(this.list, this.onChanged);

  @override
  Widget build(BuildContext context) {
    if (list.isEmpty) return const SliverToBoxAdapter();
    final count =
        (MediaQuery.of(context).size.width - (list.length - 1) * 10 - 20) ~/
            195;

    return SliverGrid(
      delegate: SliverChildBuilderDelegate(
        (_, index) => CheckboxField(
          title: list[index].item1,
          initialValue: list[index].item2,
          onChanged: (val) => onChanged(index, val),
        ),
        childCount: list.length,
      ),
      gridDelegate: _SliverGridDelegateWithFixedCrossAxisCountAndFixedHeight(
        crossAxisCount: count,
        height: Config.MATERIAL_TAP_TARGET_SIZE,
        mainAxisSpacing: 0,
        crossAxisSpacing: 10,
      ),
    );
  }
}

class _SliverGridDelegateWithFixedCrossAxisCountAndFixedHeight
    extends SliverGridDelegate {
  const _SliverGridDelegateWithFixedCrossAxisCountAndFixedHeight({
    @required this.crossAxisCount,
    @required this.height,
    this.mainAxisSpacing = 0.0,
    this.crossAxisSpacing = 0.0,
  })  : assert(crossAxisCount != null && crossAxisCount > 0),
        assert(mainAxisSpacing != null && mainAxisSpacing >= 0),
        assert(crossAxisSpacing != null && crossAxisSpacing >= 0);

  final int crossAxisCount;
  final double height;
  final double mainAxisSpacing;
  final double crossAxisSpacing;

  bool _debugAssertIsValid() {
    assert(crossAxisCount > 0);
    assert(mainAxisSpacing >= 0.0);
    assert(crossAxisSpacing >= 0.0);
    assert(height > 0.0);
    return true;
  }

  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    assert(_debugAssertIsValid());
    double usableCrossAxisExtent =
        constraints.crossAxisExtent - crossAxisSpacing * (crossAxisCount - 1);
    if (usableCrossAxisExtent < 0) usableCrossAxisExtent = 0;
    final double childCrossAxisExtent = usableCrossAxisExtent / crossAxisCount;
    // final double childMainAxisExtent = childCrossAxisExtent / childAspectRatio;
    return SliverGridRegularTileLayout(
      crossAxisCount: crossAxisCount,
      mainAxisStride: height + mainAxisSpacing,
      crossAxisStride: childCrossAxisExtent + crossAxisSpacing,
      childMainAxisExtent: height,
      childCrossAxisExtent: childCrossAxisExtent,
      reverseCrossAxis: axisDirectionIsReversed(constraints.crossAxisDirection),
    );
  }

  @override
  bool shouldRelayout(
    _SliverGridDelegateWithFixedCrossAxisCountAndFixedHeight oldDelegate,
  ) =>
      oldDelegate.crossAxisCount != crossAxisCount ||
      oldDelegate.mainAxisSpacing != mainAxisSpacing ||
      oldDelegate.crossAxisSpacing != crossAxisSpacing ||
      oldDelegate.height != height;
}
