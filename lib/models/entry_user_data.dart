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

  bool isSimilarTo(EntryUserData other) {
    return other.status == status &&
        other.progress == progress &&
        other.score == score;
  }
}
