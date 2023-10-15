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
  Anime,
  Manga,
  Character,
  Staff,
  Studio,
  User,
  Review,
}

class DiscoverFilter {
  const DiscoverFilter._({
    required this.type,
    required this.search,
    required this.mediaFilter,
    required this.hasBirthday,
    required this.reviewSort,
  });

  DiscoverFilter(DiscoverType discoverType)
      : type = discoverType,
        search = '',
        mediaFilter = DiscoverMediaFilter(),
        hasBirthday = false,
        reviewSort = ReviewSort.CREATED_AT_DESC;

  final DiscoverType type;
  final String search;
  final DiscoverMediaFilter mediaFilter;
  final bool hasBirthday;
  final ReviewSort reviewSort;

  DiscoverFilter copyWith({
    DiscoverType? type,
    String? search,
    DiscoverMediaFilter? mediaFilter,
    bool? hasBirthday,
    ReviewSort? reviewSort,
  }) =>
      DiscoverFilter._(
        type: type ?? this.type,
        search: search ?? this.search,
        mediaFilter: mediaFilter ?? this.mediaFilter,
        hasBirthday: hasBirthday ?? this.hasBirthday,
        reviewSort: reviewSort ?? this.reviewSort,
      );
}

sealed class DiscoverItems {
  const DiscoverItems();
}

class DiscoverAnimeItems extends DiscoverItems {
  const DiscoverAnimeItems(this.pages);

  final Paged<DiscoverMediaItem> pages;
}

class DiscoverMangaItems extends DiscoverItems {
  const DiscoverMangaItems(this.pages);

  final Paged<DiscoverMediaItem> pages;
}

class DiscoverCharacterItems extends DiscoverItems {
  const DiscoverCharacterItems(this.pages);

  final Paged<TileItem> pages;
}

class DiscoverStaffItems extends DiscoverItems {
  const DiscoverStaffItems(this.pages);

  final Paged<TileItem> pages;
}

class DiscoverStudioItems extends DiscoverItems {
  const DiscoverStudioItems(this.pages);

  final Paged<StudioItem> pages;
}

class DiscoverUserItems extends DiscoverItems {
  const DiscoverUserItems(this.pages);

  final Paged<UserItem> pages;
}

class DiscoverReviewItems extends DiscoverItems {
  const DiscoverReviewItems(this.pages);

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
    required this.listStatus,
    required this.releaseYear,
    required this.averageScore,
    required this.popularity,
    required this.isAdult,
  });

  factory DiscoverMediaItem(Map<String, dynamic> map) => DiscoverMediaItem._(
        id: map['id'],
        type: map['type'] == 'ANIME' ? DiscoverType.Anime : DiscoverType.Manga,
        title: map['title']['userPreferred'],
        imageUrl: map['coverImage'][Options().imageQuality.value],
        format: StringUtil.tryNoScreamingSnakeCase(map['format']),
        releaseStatus: StringUtil.tryNoScreamingSnakeCase(map['status']),
        listStatus: EntryStatus.formatText(
          map['mediaListEntry']?['status'],
          map['type'] == 'ANIME',
        ),
        releaseYear: map['startDate']?['year'],
        averageScore: map['averageScore'] ?? 0,
        popularity: map['popularity'] ?? 0,
        isAdult: map['isAdult'] ?? false,
      );

  final String? format;
  final String? releaseStatus;
  final String? listStatus;
  final int? releaseYear;
  final int averageScore;
  final int popularity;
  final bool isAdult;
}
