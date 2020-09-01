import 'package:flutter/foundation.dart';
import 'package:otraku/enums/media_list_status_enum.dart';

class ListEntryUserData {
  int id;
  MediaListStatus mediaListStatus;
  int progress;
  int progressMax;

  ListEntryUserData({
    @required this.id,
    this.mediaListStatus,
    this.progress = 0,
    this.progressMax,
  });
}
