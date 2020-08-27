import 'package:otraku/enums/media_list_status_enum.dart';

class ListEntryUserData {
  MediaListStatus mediaListStatus;
  int progress;

  ListEntryUserData({
    this.mediaListStatus,
    this.progress = 0,
  });
}
