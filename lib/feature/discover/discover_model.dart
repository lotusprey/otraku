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
  review('Review');

  const DiscoverType(this.label);

  final String label;
}

enum DiscoverItemView { detailedList, simpleGrid }

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
        entryStatus: EntryStatus.from(map['mediaListEntry']?['status']),
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
  final EntryStatus? entryStatus;
  final int? releaseYear;
  final int averageScore;
  final int popularity;
  final bool isAdult;
}
