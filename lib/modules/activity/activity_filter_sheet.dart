import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/common/utils/consts.dart';
import 'package:otraku/common/widgets/fields/stateful_tiles.dart';
import 'package:otraku/common/widgets/overlays/sheets.dart';
import 'package:otraku/modules/activity/activities_filter_provider.dart';
import 'package:otraku/modules/activity/activity_models.dart';

void showActivityFilterSheet(BuildContext context, WidgetRef ref, int id) {
  ActivitiesFilter filter = ref.read(activitiesFilterProvider(id));
  double initialHeight = MediaQuery.paddingOf(context).bottom +
      Consts.tapTargetSize * ActivityType.values.length +
      40;

  if (filter is HomeActivityFilter) {
    initialHeight += Consts.tapTargetSize * 1.5;
  }

  showSheet(
    context,
    OpaqueSheet(
      padding: EdgeInsets.zero,
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
      child: ListView(
        controller: widget.scrollCtrl,
        physics: Consts.physics,
        padding: const EdgeInsets.symmetric(vertical: 10),
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
            UserActivityFilter _ => [],
            HomeActivityFilter filter => [
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
                  padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
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
