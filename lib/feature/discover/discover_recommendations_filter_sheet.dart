import 'package:flutter/widgets.dart';
import 'package:otraku/feature/discover/discover_filter_model.dart';
import 'package:otraku/localizations/gen.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/widget/input/chip_selector.dart';
import 'package:otraku/widget/sheets.dart';

Future<void> showRecommendationsFilterSheet({
  required BuildContext context,
  required DiscoverRecommendationsFilter filter,
  required void Function(DiscoverRecommendationsFilter) onDone,
  required bool highContrast,
}) {
  final l10n = AppLocalizations.of(context)!;
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
            title: l10n.filterSort,
            items: [
              (l10n.recommendationsSortNewest, RecommendationsSort.newest),
              (l10n.recommendationsSortHighestRated, RecommendationsSort.highestRated),
              (l10n.recommendationsSortLowestRated, RecommendationsSort.lowestRated),
            ],
            value: filter.sort,
            onChanged: (v) => filter = filter.copyWith(sort: v),
            highContrast: highContrast,
          ),
          ChipSelector(
            title: l10n.filterListPresence,
            items: [(l10n.filterListPresenceIn, true), (l10n.filterListPresenceNotIn, false)],
            value: filter.inLists,
            onChanged: (v) => filter = filter.copyWith(inLists: (v,)),
            highContrast: highContrast,
          ),
        ],
      ),
    ),
  ).then((_) => onDone(filter));
}
