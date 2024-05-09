import 'package:flutter/material.dart';
import 'package:otraku/common/utils/consts.dart';
import 'package:otraku/common/widgets/overlays/sheets.dart';
import 'package:otraku/modules/filter/chip_selector.dart';
import 'package:otraku/modules/media/media_constants.dart';
import 'package:otraku/modules/review/review_models.dart';

Future<void> showReviewsFilterSheet({
  required BuildContext context,
  required ReviewsFilter filter,
  required void Function(ReviewsFilter) onDone,
}) =>
    showSheet(
      context,
      OpaqueSheet(
        initialHeight: Consts.tapTargetSize * 5,
        builder: (context, scrollCtrl) => ListView(
          controller: scrollCtrl,
          physics: Consts.physics,
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
