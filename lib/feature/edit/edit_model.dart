import 'package:otraku/extension/date_time_extension.dart';
import 'package:otraku/feature/collection/collection_models.dart';
import 'package:otraku/feature/settings/settings_model.dart';

typedef EditTag = ({int id, bool setComplete});

class EntryEdit {
  EntryEdit._({
    required this.baseEntry,
    required this.listStatus,
    required this.progress,
    required this.progressVolumes,
    required this.score,
    required this.repeat,
    required this.startedAt,
    required this.completedAt,
    required this.private,
    required this.hiddenFromStatusLists,
    required this.advancedScores,
    required this.customLists,
    required this.notes,
  });

  factory EntryEdit(
    Map<String, dynamic> map,
    Settings settings,
    bool setComplete,
  ) {
    final baseEntry = BaseEntry(map);

    final customLists = <String, bool>{};
    if (map['mediaListEntry']?['customLists'] != null) {
      for (final e in map['mediaListEntry']['customLists'].entries) {
        customLists[e.key] = e.value;
      }
    } else {
      if (map['type'] == 'ANIME') {
        for (final listName in settings.animeCustomLists) {
          customLists[listName] = false;
        }
      } else {
        for (final listName in settings.mangaCustomLists) {
          customLists[listName] = false;
        }
      }
    }

    final advancedScores = <String, double>{};
    if (map['mediaListEntry']?['advancedScores'] != null) {
      for (final e in map['mediaListEntry']['advancedScores'].entries) {
        advancedScores[e.key] = e.value.toDouble();
      }
    } else if (settings.advancedScoringEnabled) {
      for (final scoreCategory in settings.advancedScoreSections) {
        advancedScores[scoreCategory] = 0;
      }
    }

    var listStatus = baseEntry.listStatus;
    var completedAt = baseEntry.completedAt;
    var progress = baseEntry.progress;
    if (setComplete) {
      listStatus = ListStatus.completed;
      completedAt ??= DateTime.now();

      if (baseEntry.progressMax != null) progress = baseEntry.progressMax!;
    }

    return EntryEdit._(
      baseEntry: baseEntry,
      listStatus: listStatus,
      progress: progress,
      progressVolumes: baseEntry.progressVolumes,
      score: (map['mediaListEntry']?['score'] ?? 0).toDouble(),
      repeat: map['mediaListEntry']?['repeat'] ?? 0,
      notes: map['mediaListEntry']?['notes'] ?? '',
      startedAt: baseEntry.startedAt,
      completedAt: completedAt,
      private: map['mediaListEntry']?['private'] ?? false,
      hiddenFromStatusLists: map['mediaListEntry']?['hiddenFromStatusLists'] ?? false,
      advancedScores: advancedScores,
      customLists: customLists,
    );
  }

  final BaseEntry baseEntry;
  final ListStatus? listStatus;
  final int progress;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final Map<String, double> advancedScores;
  final Map<String, bool> customLists;
  int progressVolumes;
  double score;
  int repeat;
  String notes;
  bool private;
  bool hiddenFromStatusLists;

  EntryEdit copyWith({
    ListStatus? listStatus,
    int? progress,
    int? progressVolumes,
    double? score,
    int? repeat,
    String? notes,
    (DateTime?,)? startedAt,
    (DateTime?,)? completedAt,
    bool? private,
    bool? hiddenFromStatusLists,
    Map<String, double>? advancedScores,
    Map<String, bool>? customLists,
  }) =>
      EntryEdit._(
        baseEntry: baseEntry,
        listStatus: listStatus ?? this.listStatus,
        progress: progress ?? this.progress,
        progressVolumes: progressVolumes ?? this.progressVolumes,
        score: score ?? this.score,
        repeat: repeat ?? this.repeat,
        notes: notes ?? this.notes,
        startedAt: startedAt == null ? this.startedAt : startedAt.$1,
        completedAt: completedAt == null ? this.completedAt : completedAt.$1,
        private: private ?? this.private,
        hiddenFromStatusLists: hiddenFromStatusLists ?? this.hiddenFromStatusLists,
        advancedScores: advancedScores ?? this.advancedScores,
        customLists: customLists ?? this.customLists,
      );

  Map<String, dynamic> toGraphQlVariables() => {
        'mediaId': baseEntry.mediaId,
        'status': (listStatus ?? ListStatus.current).value,
        'progress': progress,
        'progressVolumes': progressVolumes,
        'score': score,
        'repeat': repeat,
        'notes': notes,
        'startedAt': startedAt?.fuzzyDate,
        'completedAt': completedAt?.fuzzyDate,
        'private': private,
        'hiddenFromStatusLists': hiddenFromStatusLists,
        'advancedScores': advancedScores.entries.map((e) => e.value).toList(),
        'customLists': customLists.entries.where((e) => e.value).map((e) => e.key).toList(),
      };
}

class BaseEntry {
  const BaseEntry._({
    required this.mediaId,
    required this.entryId,
    required this.isAnime,
    required this.listStatus,
    required this.progress,
    required this.progressMax,
    required this.progressVolumes,
    required this.progressVolumesMax,
    required this.startedAt,
    required this.completedAt,
  });

  factory BaseEntry(Map<String, dynamic> map) => BaseEntry._(
        mediaId: map['id'],
        entryId: map['mediaListEntry']?['id'],
        isAnime: map['type'] == 'ANIME',
        listStatus: ListStatus.from(map['mediaListEntry']?['status']),
        progress: map['mediaListEntry']?['progress'] ?? 0,
        progressMax: map['episodes'] ?? map['chapters'],
        progressVolumes: map['mediaListEntry']?['progressVolumes'] ?? 0,
        progressVolumesMax: map['volumes'],
        startedAt: DateTimeExtension.fromFuzzyDate(
          map['mediaListEntry']?['startedAt'],
        ),
        completedAt: DateTimeExtension.fromFuzzyDate(
          map['mediaListEntry']?['completedAt'],
        ),
      );

  final int mediaId;
  final int? entryId;
  final bool isAnime;
  final ListStatus? listStatus;
  final int progress;
  final int? progressMax;
  final int progressVolumes;
  final int? progressVolumesMax;
  final DateTime? startedAt;
  final DateTime? completedAt;
}
