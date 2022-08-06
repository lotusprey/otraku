import 'package:otraku/utils/convert.dart';
import 'package:otraku/utils/settings.dart';

class Entry {
  Entry._({
    required this.mediaId,
    required this.titles,
    required this.imageUrl,
    required this.format,
    required this.status,
    required this.entryStatus,
    required this.nextEpisode,
    required this.airingAt,
    required this.createdAt,
    required this.updatedAt,
    required this.country,
    required this.genres,
    required this.tags,
    required this.progress,
    required this.progressMax,
    required this.progressVolumes,
    required this.progressVolumesMax,
    required this.repeat,
    required this.score,
    required this.notes,
    required this.releaseStart,
    required this.releaseEnd,
    required this.watchStart,
    required this.watchEnd,
  });

  factory Entry(Map<String, dynamic> map) {
    final titles = <String>[map['media']['title']['userPreferred']];
    if (map['media']['title']['english'] != null)
      titles.add(map['media']['title']['english']);
    if (map['media']['title']['romaji'] != null)
      titles.add(map['media']['title']['romaji']);
    if (map['media']['title']['native'] != null)
      titles.add(map['media']['title']['native']);

    final tags = <int>[];
    for (final t in map['media']['tags']) tags.add(t['id']);

    return Entry._(
      mediaId: map['media']['id'],
      titles: titles,
      imageUrl: map['media']['coverImage'][Settings().imageQuality],
      format: map['media']['format'],
      status: map['media']['status'],
      entryStatus: EntryStatus.values.byName(map['status']),
      nextEpisode: map['media']['nextAiringEpisode']?['episode'],
      airingAt: map['media']['nextAiringEpisode']?['airingAt'],
      createdAt: map['createdAt'],
      updatedAt: map['updatedAt'],
      country: map['media']['countryOfOrigin'],
      genres: List.from(map['media']['genres'] ?? [], growable: false),
      tags: tags,
      progress: map['progress'] ?? 0,
      progressMax: map['media']['episodes'] ?? map['media']['chapters'],
      progressVolumes: map['progressVolumes'] ?? 0,
      progressVolumesMax: map['media']['volumes'],
      repeat: map['repeat'] ?? 0,
      score: map['score'].toDouble() ?? 0.0,
      notes: map['notes'],
      releaseStart: Convert.mapToMillis(map['media']['startDate']),
      releaseEnd: Convert.mapToMillis(map['media']['endDate']),
      watchStart: Convert.mapToMillis(map['startedAt']),
      watchEnd: Convert.mapToMillis(map['completedAt']),
    );
  }

  final int mediaId;
  final List<String> titles;
  final String imageUrl;
  final String? format;
  final String? status;
  final EntryStatus? entryStatus;
  final int? nextEpisode;
  final int? airingAt;
  final int? createdAt;
  final int? updatedAt;
  final String? country;
  final List<String> genres;
  final List<int> tags;
  int progress;
  final int? progressMax;
  final int progressVolumes;
  final int? progressVolumesMax;
  int repeat;
  double score;
  String? notes;
  int? releaseStart;
  int? releaseEnd;
  int? watchStart;
  int? watchEnd;
}

enum EntryStatus {
  CURRENT,
  PLANNING,
  COMPLETED,
  DROPPED,
  PAUSED,
  REPEATING,
}
