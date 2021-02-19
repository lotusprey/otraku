import 'package:flutter/foundation.dart';
import 'package:otraku/helpers/fn_helper.dart';
import 'package:otraku/enums/list_status.dart';

class EntryModel {
  final int mediaId;
  final int entryId;
  final String type;
  ListStatus status;
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
  Map<String, bool> customLists;

  EntryModel._({
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
    this.customLists,
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

    final Map<String, bool> customLists = {};
    if (map['mediaListEntry']['customLists'] != null)
      for (final key in map['mediaListEntry']['customLists'].keys)
        customLists[key] = map['mediaListEntry']['customLists'][key];

    return EntryModel._(
      type: map['type'],
      mediaId: map['id'],
      entryId: map['mediaListEntry']['id'],
      status: FnHelper.stringToEnum(
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
      startedAt: FnHelper.mapToDateTime(map['mediaListEntry']['startedAt']),
      completedAt: FnHelper.mapToDateTime(map['mediaListEntry']['completedAt']),
      private: map['mediaListEntry']['private'],
      hiddenFromStatusLists: map['mediaListEntry']['hiddenFromStatusLists'],
      customLists: customLists,
    );
  }
}
