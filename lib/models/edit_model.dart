import 'package:otraku/utils/convert.dart';
import 'package:otraku/constants/list_status.dart';

class EditModel {
  final int mediaId;
  int? entryId;
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

  EditModel._({
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

  factory EditModel(Map<String, dynamic> map) {
    if (map['mediaListEntry'] == null)
      return EditModel._(
        type: map['type'],
        mediaId: map['id'],
        progressMax: map['episodes'] ?? map['chapters'],
        progressVolumesMax: map['volumes'],
      );

    final advancedScores = <String, double>{};
    if (map['mediaListEntry']['advancedScores'] != null)
      for (final e in map['mediaListEntry']['advancedScores'].entries)
        advancedScores[e.key] = e.value.toDouble();

    final customLists = <String, bool>{};
    if (map['mediaListEntry']['customLists'] != null)
      for (final e in map['mediaListEntry']['customLists'].entries)
        customLists[e.key] = e.value;

    return EditModel._(
      type: map['type'],
      mediaId: map['id'],
      entryId: map['mediaListEntry']['id'],
      status: map['mediaListEntry']['status'] != null
          ? ListStatus.values.byName(map['mediaListEntry']['status'])
          : null,
      progress: map['mediaListEntry']['progress'] ?? 0,
      progressMax: map['episodes'] ?? map['chapters'],
      progressVolumes: map['mediaListEntry']['progressVolumes'] ?? 0,
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

  factory EditModel.copy(final EditModel copy) => EditModel._(
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

  factory EditModel.emptyCopy(final EditModel copy) => EditModel._(
        type: copy.type,
        mediaId: copy.mediaId,
        progressMax: copy.progressMax,
        progressVolumesMax: copy.progressVolumesMax,
      );

  Map<String, dynamic> toMap() => {
        'mediaId': mediaId,
        'status': (status ?? ListStatus.CURRENT).name,
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
