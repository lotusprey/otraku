import 'package:otraku/common/models/paged.dart';
import 'package:otraku/common/models/tile_item.dart';
import 'package:otraku/common/utils/extensions.dart';
import 'package:otraku/common/utils/options.dart';
import 'package:otraku/modules/collection/collection_models.dart';
import 'package:otraku/modules/filter/filter_models.dart';
import 'package:otraku/modules/review/review_models.dart';
import 'package:otraku/modules/studio/studio_models.dart';
import 'package:otraku/modules/user/user_models.dart';

enum DiscoverType {
  anime('Anime'),
  manga('Manga'),
  character('Character'),
  staff('Staff'),
  studio('Studio'),
  user('User'),
  review('Review');

  const DiscoverType(this.label);

  final String label;
}

class DiscoverFilter {
  const DiscoverFilter._({
    required this.type,
    required this.search,
    required this.mediaFilter,
    required this.hasBirthday,
    required this.reviewsFilter,
  });

  DiscoverFilter(DiscoverType discoverType)
      : type = discoverType,
        search = '',
        mediaFilter = DiscoverMediaFilter(),
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

sealed class DiscoverItems {
  const DiscoverItems();
}

class DiscoverAnimeItems extends DiscoverItems {
  const DiscoverAnimeItems([this.pages = const Paged()]);

  final Paged<DiscoverMediaItem> pages;
}

class DiscoverMangaItems extends DiscoverItems {
  const DiscoverMangaItems([this.pages = const Paged()]);

  final Paged<DiscoverMediaItem> pages;
}

class DiscoverCharacterItems extends DiscoverItems {
  const DiscoverCharacterItems([this.pages = const Paged()]);

  final Paged<TileItem> pages;
}

class DiscoverStaffItems extends DiscoverItems {
  const DiscoverStaffItems([this.pages = const Paged()]);

  final Paged<TileItem> pages;
}

class DiscoverStudioItems extends DiscoverItems {
  const DiscoverStudioItems([this.pages = const Paged()]);

  final Paged<StudioItem> pages;
}

class DiscoverUserItems extends DiscoverItems {
  const DiscoverUserItems([this.pages = const Paged()]);

  final Paged<UserItem> pages;
}

class DiscoverReviewItems extends DiscoverItems {
  const DiscoverReviewItems([this.pages = const Paged()]);

  final Paged<ReviewItem> pages;
}

class DiscoverMediaItem extends TileItem {
  DiscoverMediaItem._({
    required super.id,
    required super.type,
    required super.title,
    required super.imageUrl,
    required this.format,
    required this.releaseStatus,
    required this.entryStatus,
    required this.releaseYear,
    required this.averageScore,
    required this.popularity,
    required this.isAdult,
  });

  factory DiscoverMediaItem(Map<String, dynamic> map) => DiscoverMediaItem._(
        id: map['id'],
        type: map['type'] == 'ANIME' ? DiscoverType.anime : DiscoverType.manga,
        title: map['title']['userPreferred'],
        imageUrl: map['coverImage'][Options().imageQuality.value],
        format: StringUtil.tryNoScreamingSnakeCase(map['format']),
        releaseStatus: StringUtil.tryNoScreamingSnakeCase(map['status']),
        entryStatus: EntryStatus.from(map['mediaListEntry']?['status']),
        releaseYear: map['startDate']?['year'],
        averageScore: map['averageScore'] ?? 0,
        popularity: map['popularity'] ?? 0,
        isAdult: map['isAdult'] ?? false,
      );

  final String? format;
  final String? releaseStatus;
  final EntryStatus? entryStatus;
  final int? releaseYear;
  final int averageScore;
  final int popularity;
  final bool isAdult;
}
