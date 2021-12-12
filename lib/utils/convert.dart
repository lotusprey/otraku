import 'package:otraku/constants/list_status.dart';
import 'package:otraku/utils/local_settings.dart';

abstract class Convert {
  // Replaces _ with intervals and makes each word start with
  // an upper case letter and continue with lower case ones.
  static String? clarifyEnum(String? str) {
    if (str == null) return null;
    return str.splitMapJoin(
      '_',
      onMatch: (_) => ' ',
      onNonMatch: (s) => s[0].toUpperCase() + s.substring(1).toLowerCase(),
    );
  }

  /// Converts a [ListStatus] to [String], taking into account the media type.
  static String adaptListStatus(ListStatus status, bool isAnime) {
    if (status == ListStatus.CURRENT) return isAnime ? 'Watching' : 'Reading';

    if (status == ListStatus.REPEATING)
      return isAnime ? 'Rewatching' : 'Rereading';

    final str = status.name;
    return str[0] + str.substring(1).toLowerCase();
  }

  // Removes all html tags.
  static String clearHtml(String? str) {
    if (str == null) return '';
    return str.replaceAll(RegExp(r'<[^>]+>'), '');
  }

  // Converts a map (representing a date) to String.
  static String? mapToDateStr(Map<String, dynamic>? map) {
    if (map?['year'] == null) return null;

    final month = _MONTHS[map!['month']] ?? '';

    if (month == '') return '${map['year']}';

    final day = map['day'] ?? '';

    if (day == '') return '$month, ${map['year']}';

    return '$month $day, ${map['year']}';
  }

  // Converts a map (representing a date) to DateTime.
  static DateTime? mapToDateTime(Map<String, dynamic> map) {
    if (map['year'] == null || map['month'] == null || map['day'] == null)
      return null;
    return DateTime(map['year'], map['month'], map['day']);
  }

  // Converts DateTime to map.
  static Map<String, int>? dateTimeToMap(DateTime? date) {
    if (date == null) return null;
    return {'year': date.year, 'month': date.month, 'day': date.day};
  }

  // Timestamp string from seconds.
  static String millisToStr(int? seconds) {
    if (seconds == null) return '';
    final date = DateTime.fromMillisecondsSinceEpoch(seconds * 1000);

    if (LocalSettings().analogueClock) {
      final overflows = date.hour > 12;
      return '${_WEEK_DAYS[date.weekday - 1]}, ${date.day} '
          '${_MONTHS[date.month]} ${date.year}, '
          '${(date.hour <= 9 || overflows && date.hour - 12 <= 9) ? 0 : ""}'
          '${overflows ? date.hour - 12 : date.hour}:'
          '${date.minute <= 9 ? 0 : ""}${date.minute} '
          '${overflows ? "PM" : "AM"}';
    }

    return '${_WEEK_DAYS[date.weekday - 1]}, ${date.day} ${_MONTHS[date.month]} '
        '${date.year}, ${date.hour <= 9 ? 0 : ""}${date.hour}:'
        '${date.minute <= 9 ? 0 : ""}${date.minute}';
  }

  // Time until a given timestamp of seconds.
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

  static const COUNTRY_CODES = {
    'JP': 'Japan',
    'CN': 'China',
    'KR': 'South Korea',
    'TW': 'Taiwan',
  };

  static const _WEEK_DAYS = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  static const _MONTHS = {
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
