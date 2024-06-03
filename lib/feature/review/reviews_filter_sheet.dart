import 'package:flutter/material.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/widget/overlays/sheets.dart';
import 'package:otraku/feature/filter/chip_selector.dart';
import 'package:otraku/feature/media/media_models.dart';
import 'package:otraku/feature/review/review_models.dart';

Future<void> showReviewsFilterSheet({
  required BuildContext context,
  required ReviewsFilter filter,
  required void Function(ReviewsFilter) onDone,
}) =>
    showSheet(
      context,
      OpaqueSheet(
        initialHeight: Theming.tapTargetSize * 5,
        builder: (context, scrollCtrl) => ListView(
          controller: scrollCtrl,
          physics: Theming.bouncyPhysics,
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 20,
          ),
          children: [
            ChipSelector.ensureSelected(
              title: 'Sort',
              items: ReviewsSort.values.map((v) => (v.label, v)).toList(),
              value: filter.sort,
              onChanged: (v) => filter = filter.copyWith(sort: v),
            ),
            ChipSelector(
              title: 'Media Type',
              items: MediaType.values.map((v) => (v.label, v)).toList(),
              value: filter.mediaType,
              onChanged: (v) => filter = filter.copyWith(
                mediaType: () => v,
              ),
            ),
          ],
        ),
      ),
    ).then((_) => onDone(filter));
