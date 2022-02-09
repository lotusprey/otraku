import 'package:flutter/material.dart';
import 'package:otraku/models/tag_model.dart';
import 'package:otraku/constants/consts.dart';
import 'package:otraku/widgets/fields/checkbox_field.dart';

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

class TagSelectionSheet extends StatelessWidget {
  TagSelectionSheet({
    required this.tags,
    required this.inclusive,
    required this.exclusive,
  });

  final Map<String, List<TagModel>> tags;
  final List<String> inclusive;
  final List<String> exclusive;

  @override
  Widget build(BuildContext context) {
    int count = 0;
    final slivers = <Widget>[];
    slivers.add(const SliverToBoxAdapter(child: SizedBox(height: 10)));
    for (int i = 0; i < tags.length; i++) {
      slivers.add(SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(
            tags.entries.elementAt(i).key,
            style: Theme.of(context).textTheme.headline2,
          ),
        ),
      ));

      slivers.add(SliverFixedExtentList(
        delegate: SliverChildBuilderDelegate(
          (_, index) {
            final val = tags.entries.elementAt(i).value[index].name;
            return CheckBoxTriField(
              title: val,
              initial: inclusive.contains(val)
                  ? 1
                  : exclusive.contains(val)
                      ? -1
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
    slivers.add(const SliverToBoxAdapter(child: SizedBox(height: 10)));

    return Sheet(
      height: null,
      child: CustomScrollView(
        physics: Consts.PHYSICS,
        semanticChildCount: count,
        slivers: slivers,
      ),
    );
  }
}
