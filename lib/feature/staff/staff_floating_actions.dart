import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/feature/filter/chip_selector.dart';
import 'package:otraku/feature/media/media_models.dart';
import 'package:otraku/feature/staff/staff_filter_provider.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/widget/overlays/sheets.dart';

class StaffFilterButton extends StatelessWidget {
  const StaffFilterButton(this.id, this.ref)
      : super(key: const Key('filterStaff'));

  final int id;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      tooltip: 'Filter',
      heroTag: 'filter',
      child: const Icon(Ionicons.funnel_outline),
      onPressed: () {
        var filter = ref.read(staffFilterProvider(id));

        final onDone =
            (_) => ref.read(staffFilterProvider(id).notifier).state = filter;

        showSheet(
          context,
          SimpleSheet(
            initialHeight: Theming.minTapTarget * 3.5,
            builder: (context, scrollCtrl) => ListView(
              controller: scrollCtrl,
              physics: Theming.bouncyPhysics,
              padding: const EdgeInsets.symmetric(vertical: 20),
              children: [
                ChipSelector.ensureSelected(
                  title: 'Sort',
                  items: MediaSort.values.map((v) => (v.label, v)).toList(),
                  value: filter.sort,
                  onChanged: (v) => filter = filter.copyWith(sort: v),
                ),
                ChipSelector(
                  title: 'Type',
                  items: const [('Anime', true), ('Manga', false)],
                  value: filter.ofAnime,
                  onChanged: (v) => filter = filter.copyWith(
                    ofAnime: () => v,
                  ),
                ),
                const SizedBox(height: Theming.offset),
                ChipSelector(
                  title: 'List Presence',
                  items: const [
                    ('In Lists', true),
                    ('Not in Lists', false),
                  ],
                  value: filter.inLists,
                  onChanged: (v) => filter = filter.copyWith(
                    inLists: () => v,
                  ),
                ),
              ],
            ),
          ),
        ).then(onDone);
      },
    );
  }
}
