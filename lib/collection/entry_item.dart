import 'package:otraku/collection/collection_models.dart';
import 'package:otraku/utils/settings.dart';

class EntryItem {
  EntryItem._({
    required this.mediaId,
    required this.title,
    required this.imageUrl,
    required this.nextEpisode,
    required this.progressMax,
    required this.progress,
  });

  factory EntryItem(Map<String, dynamic> map) => EntryItem._(
        mediaId: map['mediaId'],
        title: map['media']['title']['userPreferred'],
        imageUrl: map['media']['coverImage'][Settings().imageQuality],
        nextEpisode: map['media']['nextAiringEpisode']?['episode'],
        progressMax: map['media']['episodes'] ?? map['media']['chapters'],
        progress: map['progress'] ?? 0,
      );

  factory EntryItem.fromEntry(Entry entry) => EntryItem._(
        mediaId: entry.mediaId,
        title: entry.titles[0],
        imageUrl: entry.imageUrl,
        nextEpisode: entry.nextEpisode,
        progressMax: entry.progressMax,
        progress: entry.progress,
      );

  final int mediaId;
  final String title;
  final String imageUrl;
  final int? nextEpisode;
  final int? progressMax;
  int progress;
}
