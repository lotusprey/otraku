import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/feature/character/character_filter_provider.dart';
import 'package:otraku/widget/input/chip_selector.dart';
import 'package:otraku/feature/media/media_models.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/widget/sheets.dart';

class CharacterMediaFilterButton extends StatelessWidget {
  const CharacterMediaFilterButton(this.id, this.ref);

  final int id;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      tooltip: 'Filter',
      child: const Icon(Ionicons.funnel_outline),
      onPressed: () {
        var filter = ref.read(characterFilterProvider(id));

        final onDone = (_) =>
            ref.read(characterFilterProvider(id).notifier).state = filter;

        showSheet(
          context,
          SimpleSheet(
            initialHeight: Theming.normalTapTarget * 2.5 +
                MediaQuery.paddingOf(context).bottom +
                40,
            builder: (context, scrollCtrl) => ListView(
              controller: scrollCtrl,
              physics: Theming.bouncyPhysics,
              padding: const EdgeInsets.symmetric(
                horizontal: Theming.offset,
                vertical: 20,
              ),
              children: [
                ChipSelector.ensureSelected(
                  title: 'Sort',
                  items: MediaSort.values.map((v) => (v.label, v)).toList(),
                  value: filter.sort,
                  onChanged: (v) => filter = filter.copyWith(sort: v),
                ),
                ChipSelector(
                  title: 'List Presence',
                  items: const [
                    ('In Lists', true),
                    ('Not in Lists', false),
                  ],
                  value: filter.inLists,
                  onChanged: (v) => filter = filter.copyWith(
                    inLists: (v,),
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
