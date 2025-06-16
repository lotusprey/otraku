import 'package:otraku/extension/string_extension.dart';
import 'package:otraku/feature/character/character_item_model.dart';
import 'package:otraku/feature/media/media_models.dart';
import 'package:otraku/feature/staff/staff_item_model.dart';
import 'package:otraku/feature/studio/studio_item_model.dart';
import 'package:otraku/feature/user/user_item_model.dart';
import 'package:otraku/feature/viewer/persistence_model.dart';
import 'package:otraku/util/paged.dart';
import 'package:otraku/feature/collection/collection_models.dart';
import 'package:otraku/feature/review/review_models.dart';

enum DiscoverType {
  anime('Anime'),
  manga('Manga'),
  character('Character'),
  staff('Staff'),
  studio('Studio'),
  user('User'),
  review('Review'),
  recommendation('Recommendation');

  const DiscoverType(this.label);

  final String label;
}

enum DiscoverItemView { detailed, simple }

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

  final Paged<CharacterItem> pages;
}

class DiscoverStaffItems extends DiscoverItems {
  const DiscoverStaffItems([this.pages = const Paged()]);

  final Paged<StaffItem> pages;
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

class DiscoverRecommendationItems extends DiscoverItems {
  const DiscoverRecommendationItems([this.pages = const Paged()]);

  final Paged<DiscoverRecommendationItem> pages;
}

class DiscoverMediaItem {
  DiscoverMediaItem._({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.isAnime,
    required this.format,
    required this.releaseStatus,
    required this.entryStatus,
    required this.releaseYear,
    required this.averageScore,
    required this.popularity,
    required this.isAdult,
  });

  factory DiscoverMediaItem(
    Map<String, dynamic> map,
    ImageQuality imageQuality,
  ) =>
      DiscoverMediaItem._(
        id: map['id'],
        name: map['title']['userPreferred'],
        imageUrl: map['coverImage'][imageQuality.value],
        isAnime: map['type'] == 'ANIME',
        format: StringExtension.tryNoScreamingSnakeCase(map['format']),
        releaseStatus: ReleaseStatus.from(map['status']),
        entryStatus: ListStatus.from(map['mediaListEntry']?['status']),
        releaseYear: map['startDate']?['year'],
        averageScore: map['averageScore'] ?? 0,
        popularity: map['popularity'] ?? 0,
        isAdult: map['isAdult'] ?? false,
      );

  final int id;
  final String name;
  final String imageUrl;
  final bool isAnime;
  final String? format;
  final ReleaseStatus? releaseStatus;
  final ListStatus? entryStatus;
  final int? releaseYear;
  final int averageScore;
  final int popularity;
  final bool isAdult;
}

class DiscoverRecommendationItem {
  DiscoverRecommendationItem._({
    required this.rating,
    required this.userRating,
    required this.mediaId,
    required this.mediaTitle,
    required this.mediaCover,
    required this.mediaListStatus,
    required this.isMediaAdult,
    required this.recommendedMediaId,
    required this.recommendedMediaTitle,
    required this.recommendedMediaCover,
    required this.recommendedMediaListStatus,
    required this.isRecommendedMediaAdult,
  });

  factory DiscoverRecommendationItem(
    Map<String, dynamic> map,
    ImageQuality imageQuality,
  ) {
    final userRating = map['userRating'] == 'RATE_UP'
        ? true
        : map['userRating'] == 'RATE_DOWN'
            ? false
            : null;

    final media = map['media'];
    final recommendedMedia = map['mediaRecommendation'];

    final isMediaAnime = switch (media['type']) {
      'ANIME' => true,
      'MANGA' => false,
      _ => null,
    };
    final isRecommendedMediaAnime = switch (media['type']) {
      'ANIME' => true,
      'MANGA' => false,
      _ => null,
    };

    return DiscoverRecommendationItem._(
      userRating: userRating,
      rating: map['rating'] ?? 0,
      mediaId: media['id'] ?? 0,
      mediaTitle: media['title']['userPreferred'] ?? '?',
      mediaCover: media['coverImage'][imageQuality.value] ?? '',
      mediaListStatus: ListStatus.from(media['mediaListEntry']?['status'])
          ?.label(isMediaAnime),
      isMediaAdult: media['isAdult'] ?? false,
      recommendedMediaId: recommendedMedia['id'] ?? 0,
      recommendedMediaTitle: recommendedMedia['title']['userPreferred'] ?? '?',
      recommendedMediaCover:
          recommendedMedia['coverImage'][imageQuality.value] ?? '',
      recommendedMediaListStatus:
          ListStatus.from(recommendedMedia['mediaListEntry']?['status'])
              ?.label(isRecommendedMediaAnime),
      isRecommendedMediaAdult: recommendedMedia['isAdult'] ?? false,
    );
  }

  int rating;
  bool? userRating;
  final int mediaId;
  final String mediaTitle;
  final String mediaCover;
  final String? mediaListStatus;
  final bool isMediaAdult;
  final int recommendedMediaId;
  final String recommendedMediaTitle;
  final String recommendedMediaCover;
  final String? recommendedMediaListStatus;
  final bool isRecommendedMediaAdult;
}
