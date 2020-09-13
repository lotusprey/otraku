import 'package:flutter/foundation.dart';
import 'package:otraku/enums/media_list_status_enum.dart';

class EntryUserData {
  int mediaId;
  int entryId;
  MediaListStatus status;
  int progress;
  int progressMax;
  double score;

  EntryUserData({
    @required this.mediaId,
    this.progress = 0,
    this.progressMax,
    this.score = 0,
    this.entryId,
    this.status,
  });

  EntryUserData.from(EntryUserData data)
      : this(
          mediaId: data.mediaId,
          progress: data.progress,
          progressMax: data.progressMax,
          score: data.score,
          entryId: data.entryId,
          status: data.status,
        );

  bool isSimilarTo(EntryUserData other) {
    return other.status == status &&
        other.progress == progress &&
        other.score == score;
  }
}
