import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/feature/filter/chip_selector.dart';
import 'package:otraku/feature/media/media_models.dart';
import 'package:otraku/feature/staff/staff_filter_provider.dart';
import 'package:otraku/feature/staff/staff_model.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/util/toast.dart';
import 'package:otraku/widget/layouts/floating_bar.dart';
import 'package:otraku/widget/overlays/sheets.dart';

class StaffFavoriteButton extends StatefulWidget {
  const StaffFavoriteButton(this.staff, this.toggleFavorite);

  final Staff staff;
  final Future<Object?> Function() toggleFavorite;

  @override
  State<StaffFavoriteButton> createState() => _StaffFavoriteButtonState();
}

class _StaffFavoriteButtonState extends State<StaffFavoriteButton> {
  @override
  Widget build(BuildContext context) {
    final staff = widget.staff;

    return ActionButton(
      icon: staff.isFavorite ? Icons.favorite : Icons.favorite_border,
      tooltip: staff.isFavorite ? 'Unfavourite' : 'Favourite',
      onTap: () async {
        setState(() => staff.isFavorite = !staff.isFavorite);

        final err = await widget.toggleFavorite();
        if (err == null) return;

        setState(() => staff.isFavorite = !staff.isFavorite);
        if (context.mounted) Toast.show(context, err.toString());
      },
    );
  }
}

class StaffFilterButton extends StatelessWidget {
  const StaffFilterButton(this.id);

  final int id;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        return ActionButton(
          icon: Ionicons.funnel_outline,
          tooltip: 'Filter',
          onTap: () {
            var filter = ref.read(staffFilterProvider(id));

            final onDone = (_) =>
                ref.read(staffFilterProvider(id).notifier).state = filter;

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
      },
    );
  }
}
