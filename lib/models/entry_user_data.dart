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
  double score;
  Map<String, bool> customLists;

  EntryUserData({
    @required this.mediaId,
    @required this.type,
    @required this.format,
    this.progress = 0,
    this.progressMax,
    this.score = 0,
    this.entryId,
    this.status,
    this.customLists = const {},
  });

  EntryUserData.from(EntryUserData data)
      : this(
          mediaId: data.mediaId,
          type: data.type,
          format: data.format,
          progress: data.progress,
          progressMax: data.progressMax,
          score: data.score,
          entryId: data.entryId,
          status: data.status,
          customLists: data.customLists,
        );
}
