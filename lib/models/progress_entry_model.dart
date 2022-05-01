import 'package:otraku/utils/settings.dart';

class ProgressEntryModel {
  ProgressEntryModel._({
    required this.mediaId,
    required this.title,
    required this.imageUrl,
    required this.progress,
    required this.progressMax,
    required this.nextEpisode,
    required this.format,
  });

  factory ProgressEntryModel(Map<String, dynamic> map) => ProgressEntryModel._(
        mediaId: map['mediaId'],
        title: map['media']['title']['userPreferred'],
        imageUrl: map['media']['coverImage'][Settings().imageQuality],
        progress: map['progress'],
        progressMax: map['media']['episodes'] ?? map['media']['chapters'],
        format: map['media']['format'],
        nextEpisode: map['media']['nextAiringEpisode']?['episode'],
      );

  final int mediaId;
  final String title;
  final String imageUrl;
  final String? format;
  final int? progressMax;
  final int? nextEpisode;
  int progress;
}
