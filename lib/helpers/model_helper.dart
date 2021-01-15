import 'dart:typed_data';

class ModelHelper {
  // Removes all the html tags in a string with regex (copied from the internet)
  static String clearHtml(String str) {
    if (str == null) return null;
    return str.replaceAll(RegExp(r'<[^>]*>'), '');
  }

  static String mapToDateString(Map<String, dynamic> map) {
    if (map['year'] == null) return null;

    final String month = _months[map['month']];
    var day = map['day'] ?? '';

    if (month == '' && day == '') return '${map['year']}';

    return '$month $day, ${map['year']}';
  }

  static DateTime mapToDateTime(Map<String, dynamic> map) {
    if (map['year'] == null || map['month'] == null || map['day'] == null)
      return null;
    return DateTime(map['year'], map['month'], map['day']);
  }

  static Map<String, int> dateTimeToMap(DateTime date) {
    if (date == null) return null;
    return {'year': date.year, 'month': date.month, 'day': date.day};
  }

  static String dateTimeToString(DateTime date) {
    if (date == null) return null;
    return '${_weekDays[date.weekday - 1]}, ${date.day} ${_months[date.month]} ${date.year}, ${date.hour}:${date.minute}';
  }

  static String secondsToShortString(int seconds) {
    int minutes = seconds ~/ 60;
    int hours = minutes ~/ 60;
    minutes %= 60;
    int days = hours ~/ 24;
    hours %= 24;

    return '${days != 0 ? '${days}d ' : ''}${hours != 0 ? '${hours}h ' : ''}${minutes != 0 ? '${minutes}m' : ''}';
  }

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

  // A transparent image, often used as a placeholder in a FadeInImage widget
  static final Uint8List transparentImage = Uint8List.fromList(<int>[
    0x89,
    0x50,
    0x4E,
    0x47,
    0x0D,
    0x0A,
    0x1A,
    0x0A,
    0x00,
    0x00,
    0x00,
    0x0D,
    0x49,
    0x48,
    0x44,
    0x52,
    0x00,
    0x00,
    0x00,
    0x01,
    0x00,
    0x00,
    0x00,
    0x01,
    0x08,
    0x06,
    0x00,
    0x00,
    0x00,
    0x1F,
    0x15,
    0xC4,
    0x89,
    0x00,
    0x00,
    0x00,
    0x0A,
    0x49,
    0x44,
    0x41,
    0x54,
    0x78,
    0x9C,
    0x63,
    0x00,
    0x01,
    0x00,
    0x00,
    0x05,
    0x00,
    0x01,
    0x0D,
    0x0A,
    0x2D,
    0xB4,
    0x00,
    0x00,
    0x00,
    0x00,
    0x49,
    0x45,
    0x4E,
    0x44,
    0xAE,
  ]);
}
