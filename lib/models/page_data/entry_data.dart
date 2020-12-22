import 'package:flutter/foundation.dart';
import 'package:otraku/enums/enum_helper.dart';
import 'package:otraku/enums/media_list_status_enum.dart';
import 'package:otraku/models/date_time_mapping.dart';
import 'package:otraku/models/tuple.dart';

class EntryData {
  final int mediaId;
  final int entryId;
  final String type;
  MediaListStatus status;
  int progress;
  final int progressMax;
  int progressVolumes;
  final int progressVolumesMax;
  double score;
  int repeat;
  String notes;
  DateTime startedAt;
  DateTime completedAt;
  bool private;
  bool hiddenFromStatusLists;
  List<Tuple<String, bool>> customLists;

  EntryData._({
    @required this.mediaId,
    @required this.type,
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
    this.customLists = const [],
  });

  factory EntryData(Map<String, dynamic> map) {
    if (map['mediaListEntry'] == null) {
      return EntryData._(
        type: map['type'],
        mediaId: map['id'],
        progressMax: map['episodes'] ?? map['chapters'],
        progressVolumesMax: map['voumes'],
      );
    }

    final List<Tuple<String, bool>> customLists = [];
    if (map['mediaListEntry']['customLists'] != null) {
      for (final key in map['mediaListEntry']['customLists'].keys) {
        customLists.add(Tuple(key, map['mediaListEntry']['customLists'][key]));
      }
    }

    return EntryData._(
      type: map['type'],
      mediaId: map['id'],
      entryId: map['mediaListEntry']['id'],
      status: stringToEnum(
        map['mediaListEntry']['status'],
        MediaListStatus.values,
      ),
      progress: map['mediaListEntry']['progress'] ?? 0,
      progressMax: map['episodes'] ?? map['chapters'],
      progressVolumes: map['mediaListEntry']['volumes'] ?? 0,
      progressVolumesMax: map['voumes'],
      score: map['mediaListEntry']['score'].toDouble(),
      repeat: map['mediaListEntry']['repeat'],
      notes: map['mediaListEntry']['notes'],
      startedAt: mapToDateTime(map['mediaListEntry']['startedAt']),
      completedAt: mapToDateTime(map['mediaListEntry']['completedAt']),
      private: map['mediaListEntry']['private'],
      hiddenFromStatusLists: map['mediaListEntry']['hiddenFromStatusLists'],
      customLists: customLists,
    );
  }

  // EntryData clone() {
  //   List<Tuple<String, bool>> customListsCopy = [];
  //   for (final tuple in customLists) {
  //     customListsCopy.add(Tuple(tuple.item1, tuple.item2));
  //   }

  //   return EntryData(
  //     mediaId: mediaId,
  //     type: type,
  //     entryId: entryId,
  //     status: status != null ? MediaListStatus.values[status.index] : null,
  //     progress: progress,
  //     progressMax: progressMax,
  //     progressVolumes: progressVolumes,
  //     progressVolumesMax: progressVolumesMax,
  //     score: score,
  //     repeat: repeat,
  //     notes: notes,
  //     startedAt:
  //         startedAt == null ? null : DateTime.parse(startedAt.toString()),
  //     completedAt:
  //         completedAt == null ? null : DateTime.parse(completedAt.toString()),
  //     private: private,
  //     hiddenFromStatusLists: hiddenFromStatusLists,
  //     customLists: customListsCopy,
  //   );
  // }
}
