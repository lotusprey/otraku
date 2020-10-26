import 'package:flutter/foundation.dart';
import 'package:otraku/enums/media_list_status_enum.dart';
import 'package:otraku/models/tuple.dart';

class EditEntry {
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

  EditEntry({
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

  EditEntry clone() {
    List<Tuple<String, bool>> customListsCopy = [];
    for (final tuple in customLists) {
      customListsCopy.add(Tuple(tuple.item1, tuple.item2));
    }

    return EditEntry(
      mediaId: mediaId,
      type: type,
      entryId: entryId,
      status: status != null ? MediaListStatus.values[status.index] : null,
      progress: progress,
      progressMax: progressMax,
      progressVolumes: progressVolumes,
      progressVolumesMax: progressVolumesMax,
      score: score,
      repeat: repeat,
      notes: notes,
      startedAt:
          startedAt == null ? null : DateTime.parse(startedAt.toString()),
      completedAt:
          completedAt == null ? null : DateTime.parse(completedAt.toString()),
      private: private,
      hiddenFromStatusLists: hiddenFromStatusLists,
      customLists: customListsCopy,
    );
  }
}
