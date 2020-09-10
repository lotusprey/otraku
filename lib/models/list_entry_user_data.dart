import 'package:flutter/foundation.dart';
import 'package:otraku/enums/media_list_status_enum.dart';

class ListEntryUserData {
  MediaListStatus mediaListStatus;
  int progress;
  int progressMax;
  double score;

  ListEntryUserData({
    @required this.mediaListStatus,
    @required this.progress,
    @required this.progressMax,
    @required this.score,
  });
}
