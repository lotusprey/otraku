import 'package:flutter/foundation.dart';
import 'package:otraku/models/date_time_mapping.dart';

class MediaListData {
  final int mediaId;
  final String title;
  final String cover;
  final String format;
  final String status;
  final int nextEpisode;
  final String timeUntilAiring;
  final int createdAt;
  final int updatedAt;
  final List<String> genres;
  int progress;
  final int progressMax;
  int progressVolumes;
  final int progressVolumesMax;
  double score;
  int repeat;
  String notes;
  DateTime startDate;
  DateTime endDate;

  MediaListData._({
    @required this.mediaId,
    @required this.title,
    @required this.cover,
    @required this.format,
    @required this.status,
    @required this.nextEpisode,
    @required this.timeUntilAiring,
    @required this.createdAt,
    @required this.updatedAt,
    @required this.genres,
    this.progress = 0,
    this.progressMax,
    this.progressVolumes = 0,
    this.progressVolumesMax,
    this.score = 0,
    this.repeat = 0,
    this.notes,
    this.startDate,
    this.endDate,
  });

  factory MediaListData(Map<String, dynamic> map) => MediaListData._(
        mediaId: map['mediaId'],
        title: map['media']['title']['userPreferred'],
        cover: map['media']['coverImage']['large'],
        nextEpisode: map['media']['nextAiringEpisode'] != null
            ? map['media']['nextAiringEpisode']['episode']
            : null,
        timeUntilAiring: map['media']['nextAiringEpisode'] != null
            ? secondsToTime(
                map['media']['nextAiringEpisode']['timeUntilAiring'])
            : null,
        format: map['media']['format'],
        status: map['media']['status'],
        progress: map['progress'],
        progressMax: map['media']['episodes'] ?? map['media']['chapters'],
        progressVolumes: map['progressVolumes'],
        progressVolumesMax: map['media']['volumes'],
        score: map['score'].toDouble(),
        startDate: mapToDateTime(map['startedAt']),
        endDate: mapToDateTime(map['completedAt']),
        repeat: map['repeat'],
        notes: map['notes'],
        createdAt: map['createdAt'],
        updatedAt: map['updatedAt'],
        genres: List.from(map['media']['genres']),
      );
}
