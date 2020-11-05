import 'package:otraku/enums/list_sort_enum.dart';
import 'package:otraku/enums/score_format_enum.dart';

class Settings {
  ScoreFormat _scoreFormat;
  ListSort _defaultSort;
  String _titleFormat;
  bool _splitCompletedAnime;
  bool _splitCompletedManga;
  bool _displayAdultContent;

  Settings(
    this._scoreFormat,
    this._defaultSort,
    this._titleFormat,
    this._splitCompletedAnime,
    this._splitCompletedManga,
    this._displayAdultContent,
  );

  ScoreFormat get scoreFormat => _scoreFormat;

  ListSort get defaultSort => _defaultSort;

  String get titleFormat => _titleFormat;

  bool get splitCompletedAnime => _splitCompletedAnime;

  bool get splitCompletedManga => _splitCompletedManga;

  bool get displayAdultContent => _displayAdultContent;
}
