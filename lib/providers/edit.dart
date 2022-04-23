import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/constants/list_status.dart';
import 'package:otraku/providers/user_settings.dart';
import 'package:otraku/utils/client.dart';
import 'package:otraku/utils/convert.dart';
import 'package:otraku/utils/graphql.dart';

final currentEditProvider = FutureProvider.autoDispose.family<Edit, int>(
  (ref, id) async {
    final data = await Client.request(GqlQuery.media, {
      'id': id,
      'withMain': true,
    });

    if (data == null) throw StateError('No received data.');

    return Edit(data['Media'], ref.watch(userSettingsProvider));
  },
);

final editProvider = StateProvider.autoDispose<Edit>(
  (ref) => Edit._(mediaId: -1),
);

class Edit {
  final int mediaId;
  final String? type;
  final ListStatus? status;
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

  factory Edit(Map<String, dynamic> map, UserSettings settings) {
    final customLists = <String, bool>{};
    if (map['mediaListEntry']?['customLists'] != null) {
      for (final e in map['mediaListEntry']['customLists'].entries)
        customLists[e.key] = e.value;
    } else {
      if (map['type'] == 'ANIME')
        for (final c in settings.animeCustomLists) customLists[c] = false;
      else
        for (final c in settings.mangaCustomLists) customLists[c] = false;
    }

    if (map['mediaListEntry'] == null)
      return Edit._(
        type: map['type'],
        mediaId: map['id'],
        progressMax: map['episodes'] ?? map['chapters'],
        progressVolumesMax: map['volumes'],
        customLists: customLists,
      );

    final advancedScores = <String, double>{};
    if (map['mediaListEntry']['advancedScores'] != null)
      for (final e in map['mediaListEntry']['advancedScores'].entries)
        advancedScores[e.key] = e.value.toDouble();

    return Edit._(
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
      notes: map['mediaListEntry']['notes'] ?? '',
      startedAt: Convert.mapToDateTime(map['mediaListEntry']['startedAt']),
      completedAt: Convert.mapToDateTime(map['mediaListEntry']['completedAt']),
      private: map['mediaListEntry']['private'],
      hiddenFromStatusLists: map['mediaListEntry']['hiddenFromStatusLists'],
      advancedScores: advancedScores,
      customLists: customLists,
    );
  }

  Edit copyWith({
    ListStatus? status,
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
        startedAt: startedAt?.call() ?? this.startedAt,
        completedAt: completedAt?.call() ?? this.completedAt,
        private: private ?? this.private,
        hiddenFromStatusLists:
            hiddenFromStatusLists ?? this.hiddenFromStatusLists,
        advancedScores: advancedScores ?? {...this.advancedScores},
        customLists: customLists ?? {...this.customLists},
      );

  Edit emptyCopy() => Edit._(
        type: type,
        mediaId: mediaId,
        progressMax: progressMax,
        progressVolumesMax: progressVolumesMax,
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
