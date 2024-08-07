import 'package:otraku/extension/date_time_extension.dart';
import 'package:otraku/feature/collection/collection_models.dart';
import 'package:otraku/feature/media/media_models.dart';
import 'package:otraku/model/tile_item.dart';
import 'package:otraku/model/paged.dart';
import 'package:otraku/util/persistence.dart';

class StudioItem {
  StudioItem._({required this.id, required this.name});

  factory StudioItem(Map<String, dynamic> map) =>
      StudioItem._(id: map['id'], name: map['name']);

  final int id;
  final String name;
}

class Studio {
  Studio._({
    required this.id,
    required this.name,
    required this.siteUrl,
    required this.favorites,
    required this.isFavorite,
  });

  factory Studio(Map<String, dynamic> map) => Studio._(
        id: map['id'],
        name: map['name'],
        siteUrl: map['siteUrl'],
        favorites: map['favourites'] ?? 0,
        isFavorite: map['isFavourite'] ?? false,
      );

  final int id;
  final String name;
  final String siteUrl;
  final int favorites;
  bool isFavorite;
}

class StudioMedia {
  const StudioMedia._({
    required this.id,
    required this.title,
    required this.cover,
    required this.format,
    required this.releaseStatus,
    required this.weightedAverageScore,
    required this.entryStatus,
    required this.startDate,
  });

  factory StudioMedia(Map<String, dynamic> map, ImageQuality imageQuality) =>
      StudioMedia._(
        id: map['id'],
        title: map['title']['userPreferred'],
        cover: map['coverImage'][imageQuality.value],
        format: MediaFormat.from(map['format']),
        releaseStatus: ReleaseStatus.from(map['status']),
        weightedAverageScore: map['averageScore'] ?? 0,
        entryStatus: EntryStatus.from(map['mediaListEntry']?['status']),
        startDate: DateTimeExtension.fuzzyDateString(map['startDate']),
      );

  final int id;
  final String title;
  final String cover;
  final MediaFormat? format;
  final ReleaseStatus? releaseStatus;
  final int weightedAverageScore;
  final EntryStatus? entryStatus;
  final String? startDate;
}

class StudioMedia1 {
  const StudioMedia1({this.media = const Paged(), this.categories = const {}});

  final Paged<TileItem> media;

  /// If the items in [media] are sorted by date, [categories] will represent
  /// each time category (e.g. "2022") and the index of the first item in
  /// [media] that is contained in this category. The index of the last item is
  /// determined by the starting index of the next category (if there is one).
  /// If the items in [media] aren't sorted by date, [categories] must be empty.
  final Map<String, int> categories;
}
