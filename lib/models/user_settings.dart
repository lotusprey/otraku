import 'package:flutter/foundation.dart';
import 'package:otraku/enums/media_list_sort_enum.dart';

class UserSettings {
  final int userId;
  final String titleFormat;
  final String scoreFormat;
  final bool splitCompletedAnime;
  final bool splitCompletedManga;
  final MediaListSort sort;
  final bool displayAdultContent;

  UserSettings({
    @required this.userId,
    @required this.scoreFormat,
    @required this.splitCompletedAnime,
    @required this.splitCompletedManga,
    @required this.sort,
    this.titleFormat,
    this.displayAdultContent,
  });
}
