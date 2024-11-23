import 'package:otraku/feature/discover/discover_model.dart';
import 'package:otraku/feature/filter/filter_discover_model.dart';
import 'package:otraku/feature/media/media_models.dart';
import 'package:otraku/feature/review/review_models.dart';

class DiscoverFilter {
  const DiscoverFilter._({
    required this.type,
    required this.search,
    required this.mediaFilter,
    required this.hasBirthday,
    required this.reviewsFilter,
  });

  DiscoverFilter(DiscoverType discoverType, MediaSort sort)
      : type = discoverType,
        search = '',
        mediaFilter = DiscoverMediaFilter(sort),
        hasBirthday = false,
        reviewsFilter = const ReviewsFilter();

  final DiscoverType type;
  final String search;
  final DiscoverMediaFilter mediaFilter;
  final bool hasBirthday;
  final ReviewsFilter reviewsFilter;

  DiscoverFilter copyWith({
    DiscoverType? type,
    String? search,
    DiscoverMediaFilter? mediaFilter,
    bool? hasBirthday,
    ReviewsFilter? reviewsFilter,
  }) =>
      DiscoverFilter._(
        type: type ?? this.type,
        search: search ?? this.search,
        mediaFilter: mediaFilter ?? this.mediaFilter,
        hasBirthday: hasBirthday ?? this.hasBirthday,
        reviewsFilter: reviewsFilter ?? this.reviewsFilter,
      );
}
