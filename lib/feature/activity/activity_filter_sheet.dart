import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/feature/activity/activities_filter_model.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/widget/fields/stateful_tiles.dart';
import 'package:otraku/widget/overlays/sheets.dart';
import 'package:otraku/feature/activity/activities_filter_provider.dart';

void showActivityFilterSheet(BuildContext context, WidgetRef ref, int id) {
  ActivitiesFilter filter = ref.read(activitiesFilterProvider(id));
  double initialHeight = MediaQuery.paddingOf(context).bottom +
      Theming.tapTargetSize * ActivityType.values.length +
      50;

  if (filter is HomeActivitiesFilter) {
    initialHeight += Theming.tapTargetSize * 1.5;
  }

  showSheet(
    context,
    OpaqueSheet(
      initialHeight: initialHeight,
      builder: (context, scrollCtrl) => _FilterList(
        filter: filter,
        onChanged: (v) => filter = v,
        scrollCtrl: scrollCtrl,
      ),
    ),
  ).then((_) {
    ref.read(activitiesFilterProvider(id).notifier).state = filter;
  });
}

class _FilterList extends StatefulWidget {
  const _FilterList({
    required this.filter,
    required this.onChanged,
    required this.scrollCtrl,
  });

  final ActivitiesFilter filter;
  final void Function(ActivitiesFilter) onChanged;
  final ScrollController scrollCtrl;

  @override
  State<_FilterList> createState() => _FilterListState();
}

class _FilterListState extends State<_FilterList> {
  late ActivitiesFilter _filter = widget.filter.copyWith(
    typeIn: [...widget.filter.typeIn],
  );

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: ListView(
        controller: widget.scrollCtrl,
        physics: Theming.bouncyPhysics,
        padding: const EdgeInsets.symmetric(vertical: Theming.offset),
        children: [
          for (final a in ActivityType.values)
            StatefulCheckboxListTile(
              title: Text(a.text),
              value: _filter.typeIn.contains(a),
              onChanged: (val) {
                setState(() {
                  val! ? _filter.typeIn.add(a) : _filter.typeIn.remove(a);
                  _filter = _filter.copyWith(typeIn: _filter.typeIn);
                });
                widget.onChanged(_filter);
              },
            ),
          ...switch (_filter) {
            UserActivitiesFilter _ => [],
            HomeActivitiesFilter filter => [
                const Divider(),
                StatefulCheckboxListTile(
                  title: const Text('My Activities'),
                  value: filter.withViewerActivities,
                  onChanged: (v) {
                    setState(
                      () => _filter = filter.copyWith(withViewerActivities: v!),
                    );
                    widget.onChanged(_filter);
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    top: Theming.offset,
                    left: Theming.offset,
                    right: Theming.offset,
                  ),
                  child: SegmentedButton(
                    segments: const [
                      ButtonSegment(
                        value: true,
                        label: Text('Following'),
                        icon: Icon(Ionicons.people_outline),
                      ),
                      ButtonSegment(
                        value: false,
                        label: Text('Global'),
                        icon: Icon(Ionicons.planet_outline),
                      ),
                    ],
                    selected: {filter.onFollowing},
                    onSelectionChanged: (v) {
                      setState(
                        () => _filter = filter.copyWith(onFollowing: v.first),
                      );
                      widget.onChanged(_filter);
                    },
                  ),
                ),
              ],
          }
        ],
      ),
    );
  }
}
