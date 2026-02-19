import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/feature/discover/discover_filter_provider.dart';
import 'package:otraku/feature/discover/discover_model.dart';
import 'package:otraku/localizations/gen.dart';
import 'package:otraku/widget/input/pill_selector.dart';
import 'package:otraku/widget/swipe_switcher.dart';
import 'package:otraku/widget/sheets.dart';

class DiscoverFloatingAction extends StatelessWidget {
  const DiscoverFloatingAction() : super(key: const Key('switchDiscover'));

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Consumer(
      builder: (context, ref, child) {
        final type = ref.watch(discoverFilterProvider.select((s) => s.type));

        return FloatingActionButton(
          tooltip: l10n.discoverCategories(DiscoverType.values.length),
          onPressed: () {
            showSheet(
              context,
              SimpleSheet(
                initialHeight: PillSelector.expectedMinHeight(DiscoverType.values.length),
                builder: (context, scrollCtrl) => PillSelector(
                  scrollCtrl: scrollCtrl,
                  selected: type.index,
                  items: DiscoverType.values.map((v) => Text(v.localize(l10n))).toList(),
                  onTap: (i) {
                    ref
                        .read(discoverFilterProvider.notifier)
                        .update((s) => s.copyWith(type: DiscoverType.values[i]));
                    Navigator.pop(context);
                  },
                ),
              ),
            );
          },
          child: SwipeSwitcher(
            index: type.index,
            onChanged: (index) => ref
                .read(discoverFilterProvider.notifier)
                .update((s) => s.copyWith(type: DiscoverType.values[index])),
            children: DiscoverType.values.map((v) => Icon(_typeIcon(v))).toList(),
          ),
        );
      },
    );
  }

  static IconData _typeIcon(DiscoverType type) => switch (type) {
    .anime => Ionicons.film_outline,
    .manga => Ionicons.book_outline,
    .character => Ionicons.man_outline,
    .staff => Ionicons.mic_outline,
    .studio => Ionicons.business_outline,
    .user => Ionicons.person_outline,
    .review => Icons.rate_review_outlined,
    .recommendation => Icons.thumb_up_outlined,
  };
}
