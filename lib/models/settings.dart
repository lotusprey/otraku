import 'package:flutter/foundation.dart';
import 'package:otraku/enums/list_sort_enum.dart';
import 'package:otraku/enums/score_format_enum.dart';

class Settings {
  final ScoreFormat scoreFormat;
  final ListSort defaultSort;
  final String titleLanguage;
  final bool splitCompletedAnime;
  final bool splitCompletedManga;
  final bool displayAdultContent;
  final bool airingNotifications;

  Settings({
    @required this.scoreFormat,
    @required this.defaultSort,
    @required this.titleLanguage,
    @required this.splitCompletedAnime,
    @required this.splitCompletedManga,
    @required this.displayAdultContent,
    @required this.airingNotifications,
  });
}
