import 'package:otraku/collection/collection_models.dart';
import 'package:otraku/utils/settings.dart';

abstract class Convert {
  /// Code points of some characters.
  static final _ampersand = '&'.codeUnitAt(0);
  static final _hashtag = '#'.codeUnitAt(0);
  static final _semicolon = ';'.codeUnitAt(0);

  /// AniList can't handle some unicode characters, so before uploading text,
  /// symbols that are too big should be represented as HTML character entity
  /// references. Important primarily for emojis, hence the name.
  static String parseEmojis(String source) {
    final runes = source.runes.toList();
    final parsedRunes = <int>[];
    for (final c in runes) {
      if (c > 0xFFFF) {
        parsedRunes.addAll(
          [_ampersand, _hashtag, ...c.toString().codeUnits, _semicolon],
        );
      } else {
        parsedRunes.add(c);
    }
      }

    return String.fromCharCodes(parsedRunes);
  }

  /// Replaces _ with intervals and makes each word start with
  /// an upper case letter and continue with lower case ones.
  static String? clarifyEnum(String? str) {
    if (str == null) return null;
    return str.splitMapJoin(
      '_',
      onMatch: (_) => ' ',
      onNonMatch: (s) => s[0].toUpperCase() + s.substring(1).toLowerCase(),
    );
  }

  /// Converts a [EntryStatus] to [String], taking into account the media type.
  static String adaptListStatus(EntryStatus status, bool isAnime) {
    if (status == EntryStatus.CURRENT) return isAnime ? 'Watching' : 'Reading';

    if (status == EntryStatus.REPEATING) {
      return isAnime ? 'Rewatching' : 'Rereading';
    }

    final str = status.name;
    return str[0] + str.substring(1).toLowerCase();
  }

  /// Removes all html tags.
  static String clearHtml(String? str) {
    if (str == null) return '';
    return str.replaceAll(RegExp(r'<[^>]+>'), '');
  }

  /// Converts a map (representing a date) to String.
  static String? mapToDateStr(Map<String, dynamic>? map) {
    if (map?['year'] == null) return null;

    final month = _months[map!['month']] ?? '';

    if (month == '') return '${map['year']}';

    final day = map['day'] ?? '';

    if (day == '') return '$month, ${map['year']}';

    return '$month $day, ${map['year']}';
  }

  /// Converts a map (representing a date) to milliseconds count.
  static int? mapToMillis(Map<String, dynamic> map) {
    if (map['year'] == null) return null;
    return DateTime(map['year'], map['month'] ?? 0, map['day'] ?? 0)
        .millisecondsSinceEpoch;
  }

  /// Converts a map (representing a date) to DateTime.
  static DateTime? mapToDateTime(Map<String, dynamic> map) {
    if (map['year'] == null || map['month'] == null || map['day'] == null) {
      return null;
    }
    return DateTime(map['year'], map['month'], map['day']);
  }

  /// Converts DateTime to map.
  static Map<String, int>? dateTimeToMap(DateTime? date) {
    if (date == null) return null;
    return {'year': date.year, 'month': date.month, 'day': date.day};
  }

  /// Timestamp string from seconds.
  static String millisToStr(int? seconds) {
    if (seconds == null) return '';
    final date = DateTime.fromMillisecondsSinceEpoch(seconds * 1000);

    if (Settings().analogueClock) {
      final overflows = date.hour > 12;
      return '${_weekDays[date.weekday - 1]}, ${date.day} '
          '${_months[date.month]} ${date.year}, '
          '${(date.hour <= 9 || overflows && date.hour - 12 <= 9) ? 0 : ""}'
          '${overflows ? date.hour - 12 : date.hour}:'
          '${date.minute <= 9 ? 0 : ""}${date.minute} '
          '${overflows ? "PM" : "AM"}';
    }

    return '${_weekDays[date.weekday - 1]}, ${date.day} ${_months[date.month]} '
        '${date.year}, ${date.hour <= 9 ? 0 : ""}${date.hour}:'
        '${date.minute <= 9 ? 0 : ""}${date.minute}';
  }

  /// Time until a given timestamp of seconds.
  static String? timeUntilTimestamp(int? seconds) {
    if (seconds == null) return null;

    final date = DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
    int minutes = date.difference(DateTime.now()).inMinutes;
    int hours = minutes ~/ 60;
    minutes %= 60;
    int days = hours ~/ 24;
    hours %= 24;
    return '${days < 1 ? "" : "${days}d "}'
        '${hours < 1 ? "" : "${hours}h "}'
        '${minutes < 1 ? "" : "${minutes}m"}';
  }

  static const countryCodes = {
    'JP': 'Japan',
    'CN': 'China',
    'KR': 'South Korea',
    'TW': 'Taiwan',
  };

  static const _weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  static const _months = {
    1: 'Jan',
    2: 'Feb',
    3: 'Mar',
    4: 'Apr',
    5: 'May',
    6: 'Jun',
    7: 'Jul',
    8: 'Aug',
    9: 'Sep',
    10: 'Oct',
    11: 'Nov',
    12: 'Dec',
    null: '',
  };
}
