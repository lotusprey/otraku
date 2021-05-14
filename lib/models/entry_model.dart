import 'package:flutter/foundation.dart';
import 'package:otraku/utils/convert.dart';
import 'package:otraku/enums/list_status.dart';

class EntryModel {
  final int mediaId;
  final int? entryId;
  final String? type;
  ListStatus? status;
  int progress;
  final int? progressMax;
  int progressVolumes;
  final int? progressVolumesMax;
  double score;
  int repeat;
  String? notes;
  DateTime? startedAt;
  DateTime? completedAt;
  bool private;
  bool hiddenFromStatusLists;
  Map<String, double> advancedScores;
  Map<String, bool> customLists;

  EntryModel._({
    required this.mediaId,
    required this.type,
    this.entryId,
    this.status,
    this.progress = 0,
    this.progressMax,
    this.progressVolumes = 0,
    this.progressVolumesMax,
    this.score = 0,
    this.repeat = 0,
    this.notes,
    this.startedAt,
    this.completedAt,
    this.private = false,
    this.hiddenFromStatusLists = false,
    this.advancedScores = const {},
    this.customLists = const {},
  });

  factory EntryModel(Map<String, dynamic> map) {
    if (map['mediaListEntry'] == null) {
      return EntryModel._(
        type: map['type'],
        mediaId: map['id'],
        progressMax: map['episodes'] ?? map['chapters'],
        progressVolumesMax: map['volumes'],
      );
    }

    final advancedScores = <String, double>{};
    if (map['mediaListEntry']['advancedScores'] != null)
      for (final e in map['mediaListEntry']['advancedScores'].entries)
        advancedScores[e.key] = e.value.toDouble();

    final customLists = <String, bool>{};
    if (map['mediaListEntry']['customLists'] != null)
      for (final e in map['mediaListEntry']['customLists'].entries)
        customLists[e.key] = e.value;

    return EntryModel._(
      type: map['type'],
      mediaId: map['id'],
      entryId: map['mediaListEntry']['id'],
      status: Convert.strToEnum(
        map['mediaListEntry']['status'],
        ListStatus.values,
      ),
      progress: map['mediaListEntry']['progress'] ?? 0,
      progressMax: map['episodes'] ?? map['chapters'],
      progressVolumes: map['mediaListEntry']['volumes'] ?? 0,
      progressVolumesMax: map['volumes'],
      score: map['mediaListEntry']['score'].toDouble(),
      repeat: map['mediaListEntry']['repeat'],
      notes: map['mediaListEntry']['notes'],
      startedAt: Convert.mapToDateTime(map['mediaListEntry']['startedAt']),
      completedAt: Convert.mapToDateTime(map['mediaListEntry']['completedAt']),
      private: map['mediaListEntry']['private'],
      hiddenFromStatusLists: map['mediaListEntry']['hiddenFromStatusLists'],
      advancedScores: advancedScores,
      customLists: customLists,
    );
  }

  factory EntryModel.copy(final EntryModel copy) => EntryModel._(
        type: copy.type,
        mediaId: copy.mediaId,
        entryId: copy.entryId,
        status: copy.status,
        progress: copy.progress,
        progressMax: copy.progressMax,
        progressVolumes: copy.progressVolumes,
        progressVolumesMax: copy.progressVolumesMax,
        score: copy.score,
        repeat: copy.repeat,
        notes: copy.notes,
        startedAt: copy.startedAt != null
            ? DateTime.fromMillisecondsSinceEpoch(
                copy.startedAt!.millisecondsSinceEpoch,
              )
            : null,
        completedAt: copy.completedAt != null
            ? DateTime.fromMillisecondsSinceEpoch(
                copy.completedAt!.millisecondsSinceEpoch,
              )
            : null,
        private: copy.private,
        hiddenFromStatusLists: copy.hiddenFromStatusLists,
        advancedScores: {...copy.advancedScores},
        customLists: {...copy.customLists},
      );

  Map<String, dynamic> toMap() => {
        'mediaId': mediaId,
        'status': describeEnum(status ?? ListStatus.CURRENT),
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
