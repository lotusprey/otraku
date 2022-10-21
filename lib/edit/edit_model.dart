import 'package:otraku/collection/collection_models.dart';
import 'package:otraku/settings/settings_provider.dart';
import 'package:otraku/utils/convert.dart';

class Edit {
  Edit._({
    required this.mediaId,
    this.type,
    this.entryId,
    this.status,
    this.progress = 0,
    this.progressMax,
    this.progressVolumes = 0,
    this.progressVolumesMax,
    this.score = 0,
    this.repeat = 0,
    this.notes = '',
    this.startedAt,
    this.completedAt,
    this.private = false,
    this.hiddenFromStatusLists = false,
    this.advancedScores = const {},
    this.customLists = const {},
  });

  factory Edit.temp() => Edit._(mediaId: -1);

  factory Edit(Map<String, dynamic> map, Settings settings) {
    final customLists = <String, bool>{};
    if (map['mediaListEntry']?['customLists'] != null) {
      for (final e in map['mediaListEntry']['customLists'].entries) {
        customLists[e.key] = e.value;
      }
    } else {
      if (map['type'] == 'ANIME') {
        for (final c in settings.animeCustomLists) {
          customLists[c] = false;
        }
      } else {
        for (final c in settings.mangaCustomLists) {
          customLists[c] = false;
        }
      }
    }

    final advancedScores = <String, double>{};
    if (map['mediaListEntry']?['advancedScores'] != null) {
      for (final e in map['mediaListEntry']['advancedScores'].entries) {
        advancedScores[e.key] = e.value.toDouble();
      }
    } else if (settings.advancedScoringEnabled) {
      for (final a in settings.advancedScores) {
        advancedScores[a] = 0;
      }
    }

    if (map['mediaListEntry'] == null) {
      return Edit._(
        type: map['type'],
        mediaId: map['id'],
        progressMax: map['episodes'] ?? map['chapters'],
        progressVolumesMax: map['volumes'],
        customLists: customLists,
        advancedScores: advancedScores,
      );
    }

    return Edit._(
      type: map['type'],
      mediaId: map['id'],
      entryId: map['mediaListEntry']['id'],
      status: map['mediaListEntry']['status'] != null
          ? EntryStatus.values.byName(map['mediaListEntry']['status'])
          : null,
      progress: map['mediaListEntry']['progress'] ?? 0,
      progressMax: map['episodes'] ?? map['chapters'],
      progressVolumes: map['mediaListEntry']['progressVolumes'] ?? 0,
      progressVolumesMax: map['volumes'],
      score: (map['mediaListEntry']['score'] ?? 0).toDouble(),
      repeat: map['mediaListEntry']['repeat'] ?? 0,
      notes: map['mediaListEntry']['notes'] ?? '',
      startedAt: Convert.mapToDateTime(map['mediaListEntry']['startedAt']),
      completedAt: Convert.mapToDateTime(map['mediaListEntry']['completedAt']),
      private: map['mediaListEntry']['private'] ?? false,
      hiddenFromStatusLists:
          map['mediaListEntry']['hiddenFromStatusLists'] ?? false,
      advancedScores: advancedScores,
      customLists: customLists,
    );
  }

  final int mediaId;
  final String? type;
  final EntryStatus? status;
  final int progress;
  final int? progressMax;
  final int progressVolumes;
  final int? progressVolumesMax;
  final double score;
  final int repeat;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final bool private;
  final bool hiddenFromStatusLists;
  final Map<String, double> advancedScores;
  final Map<String, bool> customLists;
  int? entryId;
  String notes;

  /// When an entry is removed, some of the
  /// edit's meta data can still be usefull.
  Edit emptyCopy() => Edit._(
        type: type,
        mediaId: mediaId,
        progressMax: progressMax,
        progressVolumesMax: progressVolumesMax,
      );

  /// A deep copy. If [complete] is `true`, [status], [progress],
  /// [progressVolumes] and [completedAd] will be modified appropriately.
  Edit copy([complete = false]) {
    DateTime? startedAtCopy;
    if (startedAt != null) {
      startedAtCopy = DateTime(
        startedAt!.year,
        startedAt!.month,
        startedAt!.day,
      );
    }
    DateTime? completedAtCopy;
    if (complete) {
      completedAtCopy = DateTime.now();
    } else if (completedAt != null) {
      completedAtCopy = DateTime(
        completedAt!.year,
        completedAt!.month,
        completedAt!.day,
      );
    }

    return Edit._(
      mediaId: mediaId,
      type: type,
      entryId: entryId,
      status: complete ? EntryStatus.COMPLETED : status,
      progress: complete && progressMax != null ? progressMax! : progress,
      progressMax: progressMax,
      progressVolumes: complete && progressVolumesMax != null
          ? progressVolumesMax!
          : progressVolumes,
      progressVolumesMax: progressVolumesMax,
      score: score,
      repeat: repeat,
      notes: notes,
      startedAt: startedAtCopy,
      completedAt: completedAtCopy,
      private: private,
      hiddenFromStatusLists: hiddenFromStatusLists,
      advancedScores: {...advancedScores},
      customLists: {...customLists},
    );
  }

  /// [startedAt] and [completedAt] parameters are callbacks,
  /// as `null` is a valid value for the actual fields.
  Edit copyWith({
    EntryStatus? status,
    int? progress,
    int? progressVolumes,
    double? score,
    int? repeat,
    String? notes,
    DateTime? Function()? startedAt,
    DateTime? Function()? completedAt,
    bool? private,
    bool? hiddenFromStatusLists,
    Map<String, double>? advancedScores,
    Map<String, bool>? customLists,
  }) =>
      Edit._(
        type: type,
        mediaId: mediaId,
        entryId: entryId,
        status: status ?? this.status,
        progress: progress ?? this.progress,
        progressMax: progressMax,
        progressVolumes: progressVolumes ?? this.progressVolumes,
        progressVolumesMax: progressVolumesMax,
        score: score ?? this.score,
        repeat: repeat ?? this.repeat,
        notes: notes ?? this.notes,
        startedAt: startedAt != null ? startedAt() : this.startedAt,
        completedAt: completedAt != null ? completedAt() : this.completedAt,
        private: private ?? this.private,
        hiddenFromStatusLists:
            hiddenFromStatusLists ?? this.hiddenFromStatusLists,
        advancedScores: advancedScores ?? this.advancedScores,
        customLists: customLists ?? this.customLists,
      );

  Map<String, dynamic> toMap() => {
        'mediaId': mediaId,
        'status': (status ?? EntryStatus.CURRENT).name,
        'progress': progress,
        'progressVolumes': progressVolumes,
        'score': score,
        'repeat': repeat,
        'notes': notes,
        'startedAt': Convert.dateTimeToMap(startedAt),
        'completedAt': Convert.dateTimeToMap(completedAt),
        'private': private,
        'hiddenFromStatusLists': hiddenFromStatusLists,
        'advancedScores': advancedScores.entries.map((e) => e.value).toList(),
        'customLists': customLists.entries
            .where((e) => e.value)
            .map((e) => e.key)
            .toList(),
      };
}
