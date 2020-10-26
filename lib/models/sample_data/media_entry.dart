import 'package:flutter/foundation.dart';

class MediaEntry {
  final int mediaId;
  final String title;
  final String cover;
  final String format;
  final int nextEpisode;
  final String timeUntilAiring;
  final int createdAt;
  final int updatedAt;
  int progress;
  final int progressMax;
  int progressVolumes;
  final int progressVolumesMax;
  double score;
  int repeat;
  String notes;
  DateTime startDate;
  DateTime endDate;

  MediaEntry({
    @required this.mediaId,
    @required this.title,
    @required this.cover,
    @required this.format,
    @required this.nextEpisode,
    @required this.timeUntilAiring,
    @required this.createdAt,
    @required this.updatedAt,
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
}
