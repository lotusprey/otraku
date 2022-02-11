import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otraku/controllers/explore_controller.dart';
import 'package:otraku/models/tag_collection_model.dart';
import 'package:otraku/constants/consts.dart';
import 'package:otraku/widgets/fields/checkbox_field.dart';
import 'package:otraku/widgets/fields/chip_fields.dart';

class Sheet extends StatelessWidget {
  static Future<T?> show<T>({
    required BuildContext ctx,
    required Widget sheet,
    bool isScrollControlled = true,
    Color? barrierColour,
  }) =>
      showModalBottomSheet<T>(
        context: ctx,
        builder: (_) => sheet,
        isScrollControlled: isScrollControlled,
        backgroundColor: Colors.transparent,
        barrierColor:
            barrierColour ?? Theme.of(ctx).colorScheme.surface.withAlpha(150),
      );

  Sheet({
    required this.child,
    this.height,
    this.onDone,
  });

  final Widget child;
  final double? height;
  final void Function()? onDone;

  @override
  Widget build(BuildContext context) {
    final sidePadding = 10.0 +
        (MediaQuery.of(context).size.width > Consts.OVERLAY_TIGHT
            ? (MediaQuery.of(context).size.width - Consts.OVERLAY_TIGHT) / 2
            : 0.0);

    return Container(
      height: height != null
          ? (height! + MediaQuery.of(context).viewPadding.bottom)
          : null,
      margin: EdgeInsets.only(
        left: sidePadding,
        right: sidePadding,
        bottom: MediaQuery.of(context).viewPadding.bottom,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background,
        borderRadius: BorderRadius.vertical(top: Consts.RADIUS),
        boxShadow: const [
          BoxShadow(
            blurRadius: 15,
            offset: Offset(5, 5),
            color: Colors.black45,
          ),
        ],
      ),
      child: onDone == null
          ? child
          : Column(
              children: [
                Expanded(child: child),
                TextButton.icon(
                  onPressed: () {
                    onDone!();
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    Icons.done_rounded,
                    color: Theme.of(context).colorScheme.secondary,
                    size: Consts.ICON_SMALL,
                  ),
                  label: Text('Done',
                      style: Theme.of(context).textTheme.bodyText1),
                ),
              ],
            ),
    );
  }
}

class SelectionSheet<T> extends StatelessWidget {
  SelectionSheet({
    required this.options,
    required this.values,
    required this.selected,
    this.fixHeight = false,
  });

  final List<String> options;
  final List<T> values;
  final List<T> selected;
  final bool fixHeight;

  @override
  Widget build(BuildContext context) => Sheet(
        height: fixHeight
            ? options.length * Consts.MATERIAL_TAP_TARGET_SIZE + 20
            : null,
        child: ListView.builder(
          physics:
              fixHeight ? const NeverScrollableScrollPhysics() : Consts.PHYSICS,
          padding: const EdgeInsets.symmetric(vertical: 10),
          itemBuilder: (_, index) => CheckBoxField(
            title: options[index],
            initial: selected.contains(values[index]),
            onChanged: (v) => v
                ? selected.add(values[index])
                : selected.remove(values[index]),
          ),
          itemCount: options.length,
          itemExtent: Consts.MATERIAL_TAP_TARGET_SIZE,
        ),
      );
}

class SelectionToggleSheet<T> extends StatelessWidget {
  SelectionToggleSheet({
    required this.options,
    required this.values,
    required this.inclusive,
    required this.exclusive,
    this.fixHeight = false,
  });

  final List<String> options;
  final List<T> values;
  final List<T> inclusive;
  final List<T> exclusive;
  final bool fixHeight;

  @override
  Widget build(BuildContext context) => Sheet(
        height: fixHeight
            ? options.length * Consts.MATERIAL_TAP_TARGET_SIZE + 20
            : null,
        child: ListView.builder(
          physics:
              fixHeight ? const NeverScrollableScrollPhysics() : Consts.PHYSICS,
          padding: const EdgeInsets.symmetric(vertical: 10),
          itemBuilder: (_, index) => CheckBoxTriField(
            title: options[index],
            initial: inclusive.contains(values[index])
                ? 1
                : exclusive.contains(values[index])
                    ? -1
                    : 0,
            onChanged: (state) {
              if (state == 0)
                exclusive.remove(values[index]);
              else if (state == 1)
                inclusive.add(values[index]);
              else {
                inclusive.remove(values[index]);
                exclusive.add(values[index]);
              }
            },
          ),
          itemCount: options.length,
          itemExtent: Consts.MATERIAL_TAP_TARGET_SIZE,
        ),
      );
}

class TagSheet extends StatelessWidget {
  TagSheet({
    required this.inclusiveGenres,
    required this.exclusiveGenres,
    required this.inclusiveTags,
    required this.exclusiveTags,
  });

  final List<String> inclusiveGenres;
  final List<String> exclusiveGenres;
  final List<String> inclusiveTags;
  final List<String> exclusiveTags;

  @override
  Widget build(BuildContext context) {
    Widget? sheet;

    return DraggableScrollableSheet(
      expand: false,
      maxChildSize: 0.9,
      builder: (_, scrollCtrl) {
        if (sheet == null)
          sheet = Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: Consts.OVERLAY_WIDE),
              child: Container(
                padding: const EdgeInsets.only(top: 20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.background,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: _TagSheetBody(
                  inclusiveGenres: inclusiveGenres,
                  exclusiveGenres: exclusiveGenres,
                  inclusiveTags: inclusiveTags,
                  exclusiveTags: exclusiveTags,
                  scrollCtrl: scrollCtrl,
                ),
              ),
            ),
          );

        return sheet!;
      },
    );
  }
}

class _TagSheetBody extends StatefulWidget {
  _TagSheetBody({
    required this.inclusiveGenres,
    required this.exclusiveGenres,
    required this.inclusiveTags,
    required this.exclusiveTags,
    required this.scrollCtrl,
  });

  final List<String> inclusiveGenres;
  final List<String> exclusiveGenres;
  final List<String> inclusiveTags;
  final List<String> exclusiveTags;
  final ScrollController scrollCtrl;

  @override
  __TagSheetBodyState createState() => __TagSheetBodyState();
}

class __TagSheetBodyState extends State<_TagSheetBody> {
  late final TagCollectionModel _tags;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _tags = Get.find<ExploreController>().tagCollection;
  }

  @override
  Widget build(BuildContext context) {
    final listItems = _tags.categoryItems[_index];
    late final List<String> inclusive;
    late final List<String> exclusive;
    if (_index > 0) {
      inclusive = widget.inclusiveTags;
      exclusive = widget.exclusiveTags;
    } else {
      inclusive = widget.inclusiveGenres;
      exclusive = widget.exclusiveGenres;
    }

    return Column(
      children: [
        Container(
          height: 50,
          child: ListView.builder(
            physics: Consts.PHYSICS,
            padding: const EdgeInsets.symmetric(horizontal: 5),
            scrollDirection: Axis.horizontal,
            itemCount: _tags.categoryNames.length,
            itemBuilder: (_, i) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: ChipOptionField(
                name: _tags.categoryNames[i],
                selected: i == _index,
                onTap: () => setState(() => _index = i),
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            physics: Consts.PHYSICS,
            padding: Consts.PADDING,
            controller: widget.scrollCtrl,
            itemExtent: Consts.MATERIAL_TAP_TARGET_SIZE,
            itemCount: listItems.length,
            itemBuilder: (_, i) {
              final name = _tags.names[listItems[i]];
              return CheckBoxTriField(
                key: UniqueKey(),
                title: name,
                initial: inclusive.contains(name)
                    ? 1
                    : exclusive.contains(name)
                        ? -1
                        : 0,
                onChanged: (state) {
                  if (state == 0)
                    exclusive.remove(name);
                  else if (state == 1)
                    inclusive.add(name);
                  else {
                    inclusive.remove(name);
                    exclusive.add(name);
                  }
                },
              );
            },
          ),
        )
      ],
    );
  }
}
