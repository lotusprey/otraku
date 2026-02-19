import 'package:flutter/material.dart';
import 'package:otraku/localizations/gen.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/widget/sheets.dart';
import 'package:otraku/widget/input/chip_selector.dart';
import 'package:otraku/feature/media/media_models.dart';
import 'package:otraku/feature/review/review_models.dart';

Future<void> showReviewsFilterSheet({
  required BuildContext context,
  required ReviewsFilter filter,
  required void Function(ReviewsFilter) onDone,
  required bool highContrast,
}) {
  final l10n = AppLocalizations.of(context)!;

  return showSheet(
    context,
    SimpleSheet(
      initialHeight: Theming.minTapTarget * 3.5,
      builder: (context, scrollCtrl) => ListView(
        controller: scrollCtrl,
        physics: Theming.bouncyPhysics,
        padding: const .symmetric(horizontal: Theming.offset, vertical: 20),
        children: [
          ChipSelector.ensureSelected(
            title: l10n.filterSort,
            items: ReviewsSort.values.map((v) => (v.localize(l10n), v)).toList(),
            value: filter.sort,
            onChanged: (v) => filter = filter.copyWith(sort: v),
            highContrast: highContrast,
          ),
          ChipSelector(
            title: l10n.mediaType,
            items: MediaType.values.map((v) => (v.localize(l10n), v)).toList(),
            value: filter.mediaType,
            onChanged: (v) => filter = filter.copyWith(mediaType: (v,)),
            highContrast: highContrast,
          ),
        ],
      ),
    ),
  ).then((_) => onDone(filter));
}
