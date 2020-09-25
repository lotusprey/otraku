import 'package:flutter/foundation.dart';
import 'package:otraku/enums/media_list_status_enum.dart';

class EntryUserData {
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
  Map<String, bool> customLists;

  EntryUserData({
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
    this.customLists = const {},
  });

  EntryUserData.from(EntryUserData data)
      : this(
          mediaId: data.mediaId,
          entryId: data.entryId,
          type: data.type,
          format: data.format,
          status: data.status,
          progress: data.progress,
          progressMax: data.progressMax,
          score: data.score,
          repeat: data.repeat,
          customLists: data.customLists,
        );
}
