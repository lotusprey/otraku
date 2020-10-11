import 'package:flutter/foundation.dart';
import 'package:otraku/enums/media_list_status_enum.dart';
import 'package:otraku/models/tuple.dart';

class EntryData {
  final int mediaId;
  final int entryId;
  final String type;
  final String format;
  MediaListStatus status;
  int progress;
  final int progressMax;
  int progressVolumes;
  final int progressVolumesMax;
  double score;
  int repeat;
  String notes;
  DateTime startDate;
  DateTime endDate;
  bool private;
  bool hiddenFromStatusLists;
  List<Tuple<String, bool>> customLists;

  EntryData({
    @required this.mediaId,
    @required this.type,
    @required this.format,
    this.entryId,
    this.status,
    this.progress = 0,
    this.progressMax,
    this.progressVolumes = 0,
    this.progressVolumesMax,
    this.score = 0,
    this.repeat = 0,
    this.notes = '',
    this.startDate,
    this.endDate,
    this.private = false,
    this.hiddenFromStatusLists = false,
    this.customLists = const [],
  });

  EntryData clone() {
    List<Tuple<String, bool>> customListsCopy = [];
    for (final tuple in customLists) {
      customListsCopy.add(Tuple(tuple.item1, tuple.item2));
    }

    return EntryData(
      mediaId: mediaId,
      type: type,
      format: format,
      entryId: entryId,
      status: status != null ? MediaListStatus.values[status.index] : null,
      progress: progress,
      progressMax: progressMax,
      progressVolumes: progressVolumes,
      progressVolumesMax: progressVolumesMax,
      score: score,
      repeat: repeat,
      notes: notes,
      startDate:
          startDate == null ? null : DateTime.parse(startDate.toString()),
      endDate: endDate == null ? null : DateTime.parse(endDate.toString()),
      private: private,
      hiddenFromStatusLists: hiddenFromStatusLists,
      customLists: customListsCopy,
    );
  }
}
