import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/common/utils/extensions.dart';
import 'package:otraku/modules/filter/chip_selector.dart';
import 'package:otraku/modules/media/media_models.dart';
import 'package:otraku/modules/staff/staff_filter_provider.dart';
import 'package:otraku/modules/staff/staff_models.dart';
import 'package:otraku/modules/staff/staff_provider.dart';
import 'package:otraku/common/utils/consts.dart';
import 'package:otraku/common/widgets/layouts/floating_bar.dart';
import 'package:otraku/common/widgets/overlays/sheets.dart';

class StaffFavoriteButton extends StatefulWidget {
  const StaffFavoriteButton(this.data);

  final Staff data;

  @override
  State<StaffFavoriteButton> createState() => _StaffFavoriteButtonState();
}

class _StaffFavoriteButtonState extends State<StaffFavoriteButton> {
  @override
  Widget build(BuildContext context) {
    return ActionButton(
      icon: widget.data.isFavorite ? Icons.favorite : Icons.favorite_border,
      tooltip: widget.data.isFavorite ? 'Unfavourite' : 'Favourite',
      onTap: () {
        setState(() => widget.data.isFavorite = !widget.data.isFavorite);
        toggleFavoriteStaff(widget.data.id).then((ok) {
          if (!ok) {
            setState(() => widget.data.isFavorite = !widget.data.isFavorite);
          }
        });
      },
    );
  }
}

class StaffFilterButton extends StatelessWidget {
  const StaffFilterButton(this.id, this.full);

  final int id;
  final bool full;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        return ActionButton(
          icon: Ionicons.funnel_outline,
          tooltip: 'Filter',
          onTap: () {
            var filter = ref.read(staffFilterProvider(id));

            final sortItems = <String, int>{};
            for (int i = 0; i < MediaSort.values.length; i += 2) {
              String key = MediaSort.values[i].name.noScreamingSnakeCase;
              sortItems[key] = i ~/ 2;
            }

            final onDone = (_) =>
                ref.read(staffFilterProvider(id).notifier).state = filter;

            showSheet(
              context,
              OpaqueSheet(
                initialHeight: Consts.tapTargetSize * (full ? 5.5 : 4),
                builder: (context, scrollCtrl) => ListView(
                  controller: scrollCtrl,
                  physics: Consts.physics,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  children: [
                    ChipSelector.ensureSelected(
                      title: 'Sort',
                      items: MediaSort.values.map((v) => (v.label, v)).toList(),
                      value: filter.sort,
                      onChanged: (v) => filter = filter.copyWith(sort: v),
                    ),
                    if (full) ...[
                      ChipSelector(
                        title: 'Type',
                        items: const [('Anime', true), ('Manga', false)],
                        value: filter.ofAnime,
                        onChanged: (v) => filter = filter.copyWith(
                          ofAnime: () => v,
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
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
      },
    );
  }
}
