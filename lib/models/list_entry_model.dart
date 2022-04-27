import 'package:otraku/constants/list_status.dart';
import 'package:otraku/utils/convert.dart';
import 'package:otraku/utils/settings.dart';

class ListEntryModel {
  final int mediaId;
  final List<String> titles;
  final String cover;
  final String? format;
  final String? status;
  final int? nextEpisode;
  final int? airingAt;
  final int? createdAt;
  final int? updatedAt;
  int progress;
  final int? progressMax;
  final int progressVolumes;
  final int? progressVolumesMax;
  final ListStatus? listStatus;
  final String? country;
  final List<String> genres;
  final List<int> tags;
  double score;
  int repeat;
  String? notes;
  int? releaseStart;
  int? releaseEnd;
  int? watchStart;
  int? watchEnd;

  ListEntryModel._({
    required this.mediaId,
    required this.titles,
    required this.cover,
    required this.format,
    required this.status,
    required this.listStatus,
    required this.nextEpisode,
    required this.airingAt,
    required this.createdAt,
    required this.updatedAt,
    required this.genres,
    required this.tags,
    required this.progress,
    required this.progressMax,
    required this.progressVolumes,
    required this.progressVolumesMax,
    required this.score,
    required this.repeat,
    required this.notes,
    required this.releaseStart,
    required this.releaseEnd,
    required this.watchStart,
    required this.watchEnd,
    required this.country,
  });

  factory ListEntryModel(Map<String, dynamic> map) {
    final titles = <String>[map['media']['title']['userPreferred']];
    if (map['media']['title']['english'] != null)
      titles.add(map['media']['title']['english']);
    if (map['media']['title']['romaji'] != null)
      titles.add(map['media']['title']['romaji']);
    if (map['media']['title']['native'] != null)
      titles.add(map['media']['title']['native']);

    final tags = <int>[];
    for (final t in map['media']['tags']) tags.add(t['id']);

    return ListEntryModel._(
      mediaId: map['media']['id'],
      titles: titles,
      cover: map['media']['coverImage'][Settings().imageQuality],
      nextEpisode: map['media']['nextAiringEpisode']?['episode'],
      airingAt: map['media']['nextAiringEpisode']?['airingAt'],
      format: map['media']['format'],
      status: map['media']['status'],
      progress: map['progress'] ?? 0,
      progressMax: map['media']['episodes'] ?? map['media']['chapters'],
      progressVolumes: map['progressVolumes'] ?? 0,
      progressVolumesMax: map['media']['volumes'],
      score: (map['score'] ?? 0).toDouble(),
      listStatus: map['status'] != null
          ? ListStatus.values.byName(map['status'])
          : null,
      releaseStart: Convert.mapToMillis(map['media']['startDate']),
      releaseEnd: Convert.mapToMillis(map['media']['endDate']),
      watchStart: Convert.mapToMillis(map['startedAt']),
      watchEnd: Convert.mapToMillis(map['completedAt']),
      repeat: map['repeat'] ?? 0,
      notes: map['notes'],
      createdAt: map['createdAt'],
      updatedAt: map['updatedAt'],
      genres: List.from(map['media']['genres'] ?? [], growable: false),
      tags: tags,
      country: map['media']['countryOfOrigin'],
    );
  }
}
