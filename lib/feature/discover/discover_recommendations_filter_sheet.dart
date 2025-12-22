import 'package:flutter/widgets.dart';
import 'package:otraku/feature/discover/discover_filter_model.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/widget/input/chip_selector.dart';
import 'package:otraku/widget/sheets.dart';

Future<void> showRecommendationsFilterSheet({
  required BuildContext context,
  required DiscoverRecommendationsFilter filter,
  required void Function(DiscoverRecommendationsFilter) onDone,
  required bool highContrast,
}) {
  return showSheet(
    context,
    SimpleSheet(
      initialHeight: Theming.normalTapTarget * 2.5 + MediaQuery.paddingOf(context).bottom + 40,
      builder: (context, scrollCtrl) => ListView(
        controller: scrollCtrl,
        physics: Theming.bouncyPhysics,
        padding: const .symmetric(horizontal: Theming.offset, vertical: 20),
        children: [
          ChipSelector.ensureSelected(
            title: 'Sort',
            items: const [
              ('Recent', RecommendationsSort.recent),
              ('Highest Rated', RecommendationsSort.highestRated),
              ('Lowest Rated', RecommendationsSort.lowestRated),
            ],
            value: filter.sort,
            onChanged: (v) => filter = filter.copyWith(sort: v),
            highContrast: highContrast,
          ),
          ChipSelector(
            title: 'List Presence',
            items: const [('In Lists', true), ('Not in Lists', false)],
            value: filter.inLists,
            onChanged: (v) => filter = filter.copyWith(inLists: (v,)),
            highContrast: highContrast,
          ),
        ],
      ),
    ),
  ).then((_) => onDone(filter));
}
