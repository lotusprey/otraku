import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otraku/controllers/collection_controller.dart';
import 'package:otraku/models/tag_model.dart';
import 'package:otraku/constants/consts.dart';
import 'package:otraku/constants/entry_sort.dart';
import 'package:otraku/constants/media_sort.dart';
import 'package:otraku/utils/filterable.dart';
import 'package:otraku/utils/convert.dart';
import 'package:otraku/widgets/fields/three_state_field.dart';
import 'package:otraku/widgets/fields/two_state_field.dart';

class Sheet extends StatelessWidget {
  static void show({
    required BuildContext ctx,
    required Widget sheet,
    bool isScrollControlled = true,
    Color? barrierColour,
  }) =>
      showModalBottomSheet(
        context: ctx,
        builder: (_) => sheet,
        isScrollControlled: isScrollControlled,
        backgroundColor: Colors.transparent,
        barrierColor: barrierColour ??
            Theme.of(ctx).colorScheme.background.withAlpha(200),
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
    final bottomMargin = MediaQuery.of(context).viewPadding.bottom + 20;
    final sideMargin = MediaQuery.of(context).size.width > 420
        ? (MediaQuery.of(context).size.width - 400) / 2
        : 20.0;

    return Container(
      height: height != null ? (height! + bottomMargin) : null,
      margin: EdgeInsets.only(
        left: sideMargin,
        right: sideMargin,
        bottom: bottomMargin,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background,
        borderRadius: Consts.BORDER_RADIUS,
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
    required this.onDone,
    required this.options,
    required this.values,
    required this.names,
    this.fixHeight = false,
  });

  final List<String> options;
  final List<T> values;
  final List<T> names;
  final void Function(List<T>) onDone;
  final bool fixHeight;

  @override
  Widget build(BuildContext context) => Sheet(
        height: fixHeight
            ? options.length * Consts.MATERIAL_TAP_TARGET_SIZE + 50
            : null,
        child: ListView.builder(
          physics:
              fixHeight ? const NeverScrollableScrollPhysics() : Consts.PHYSICS,
          padding: const EdgeInsets.symmetric(vertical: 10),
          itemBuilder: (_, index) => TwoStateField(
            title: options[index],
            initial: names.contains(values[index]),
            onChanged: (val) =>
                val ? names.add(values[index]) : names.remove(values[index]),
          ),
          itemCount: options.length,
          itemExtent: Consts.MATERIAL_TAP_TARGET_SIZE,
        ),
        onDone: () => onDone(names),
      );
}

class SelectionToggleSheet<T> extends StatelessWidget {
  SelectionToggleSheet({
    required this.onDone,
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
  final void Function(List<T>, List<T>) onDone;
  final bool fixHeight;

  @override
  Widget build(BuildContext context) => Sheet(
        height: fixHeight
            ? options.length * Consts.MATERIAL_TAP_TARGET_SIZE + 50
            : null,
        child: ListView.builder(
          physics:
              fixHeight ? const NeverScrollableScrollPhysics() : Consts.PHYSICS,
          padding: const EdgeInsets.symmetric(vertical: 10),
          itemBuilder: (_, index) => ThreeStateField(
            title: options[index],
            initialState: inclusive.contains(values[index])
                ? 1
                : exclusive.contains(values[index])
                    ? 2
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
        onDone: () => onDone(inclusive, exclusive),
      );
}

class TagSelectionSheet extends StatelessWidget {
  TagSelectionSheet({
    required this.tags,
    required this.inclusive,
    required this.exclusive,
    required this.onDone,
  });

  final Map<String, List<TagModel>> tags;
  final List<String> inclusive;
  final List<String> exclusive;
  final void Function(List<String>, List<String>) onDone;

  @override
  Widget build(BuildContext context) {
    int count = 0;
    final slivers = <Widget>[];
    for (int i = 0; i < tags.length; i++) {
      slivers.add(SliverToBoxAdapter(
        child: Padding(
          padding: Consts.PADDING,
          child: Text(
            tags.entries.elementAt(i).key,
            style: Theme.of(context).textTheme.headline1,
          ),
        ),
      ));

      slivers.add(SliverFixedExtentList(
        delegate: SliverChildBuilderDelegate(
          (_, index) {
            final val = tags.entries.elementAt(i).value[index].name;
            return ThreeStateField(
              title: val,
              initialState: inclusive.contains(val)
                  ? 1
                  : exclusive.contains(val)
                      ? 2
                      : 0,
              onChanged: (state) {
                if (state == 0)
                  exclusive.remove(val);
                else if (state == 1)
                  inclusive.add(val);
                else {
                  inclusive.remove(val);
                  exclusive.add(val);
                }
              },
            );
          },
          childCount: tags.entries.elementAt(i).value.length,
          semanticIndexOffset: count,
        ),
        itemExtent: Consts.MATERIAL_TAP_TARGET_SIZE,
      ));

      count += tags.entries.elementAt(i).value.length;
    }

    return Sheet(
      height: null,
      child: CustomScrollView(
        physics: Consts.PHYSICS,
        semanticChildCount: count,
        slivers: slivers,
      ),
      onDone: () => onDone(inclusive, exclusive),
    );
  }
}

class CollectionSortSheet extends StatelessWidget {
  CollectionSortSheet(this.ctrlTag);

  final String ctrlTag;

  @override
  Widget build(BuildContext context) {
    final collection = Get.find<CollectionController>(tag: ctrlTag);
    final EntrySort entrySort = collection.getFilterWithKey(Filterable.SORT);

    int index = entrySort.index ~/ 2;
    bool desc = entrySort.index % 2 != 0;
    final options = <String>[];
    for (int i = 0; i < EntrySort.values.length; i += 2)
      options.add(Convert.clarifyEnum(EntrySort.values[i].name)!);

    return Sheet(
      height: options.length * 40 + 58,
      onDone: () {
        collection.setFilterWithKey(
          Filterable.SORT,
          value: desc
              ? EntrySort.values[index * 2 + 1]
              : EntrySort.values[index * 2],
        );
        collection.sort();
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          Text('Sort', style: Theme.of(context).textTheme.subtitle1),
          Expanded(
            child: _Sorting(
              onChanged: (i, d) {
                index = i;
                desc = d;
              },
              names: options,
              index: index,
              desc: desc,
            ),
          ),
        ],
      ),
    );
  }
}

class MediaSortSheet extends StatelessWidget {
  MediaSortSheet(this.initial, this.onTap);

  final MediaSort initial;
  final void Function(MediaSort) onTap;

  @override
  Widget build(BuildContext context) {
    int index = initial.index ~/ 2;
    bool desc = initial.index % 2 != 0;
    final options = <String>[];
    for (int i = 0; i < MediaSort.values.length; i += 2)
      options.add(Convert.clarifyEnum(MediaSort.values[i].name)!);

    return Sheet(
      height: options.length * 40 + 58,
      onDone: () => desc
          ? onTap(MediaSort.values[index * 2 + 1])
          : onTap(MediaSort.values[index * 2]),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          Text('Sort', style: Theme.of(context).textTheme.subtitle1),
          Expanded(
            child: _Sorting(
              onChanged: (i, d) {
                index = i;
                desc = d;
              },
              names: options,
              index: index,
              desc: desc,
            ),
          ),
        ],
      ),
    );
  }
}

class _Sorting extends StatefulWidget {
  _Sorting({
    required this.names,
    required this.onChanged,
    required this.index,
    required this.desc,
  });

  final List<String> names;
  final void Function(int, bool) onChanged;
  final int index;
  final bool desc;

  @override
  _SortingState createState() => _SortingState();
}

class _SortingState extends State<_Sorting> {
  late int _index;
  late bool _desc;

  @override
  void initState() {
    super.initState();
    _index = widget.index;
    _desc = widget.desc;
  }

  @override
  Widget build(BuildContext context) => ListView.builder(
        physics: const BouncingScrollPhysics(),
        itemCount: widget.names.length,
        itemExtent: 40,
        itemBuilder: (_, i) => GestureDetector(
          behavior: HitTestBehavior.opaque,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.names[i],
                style: i != _index
                    ? Theme.of(context).textTheme.bodyText2
                    : Theme.of(context).textTheme.bodyText1,
              ),
              if (i == _index)
                Icon(
                  _desc
                      ? Icons.arrow_downward_rounded
                      : Icons.arrow_upward_rounded,
                  color: Theme.of(context).colorScheme.secondary,
                  size: Consts.ICON_SMALL,
                ),
            ],
          ),
          onTap: () {
            i != _index
                ? setState(() => _index = i)
                : setState(() => _desc = !_desc);
            widget.onChanged(_index, _desc);
          },
        ),
      );
}
