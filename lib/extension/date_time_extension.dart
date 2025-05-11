extension DateTimeExtension on DateTime {
  int get secondsSinceEpoch => millisecondsSinceEpoch ~/ 1000;

  static DateTime fromSecondsSinceEpoch(int seconds) =>
      DateTime.fromMillisecondsSinceEpoch(seconds * 1000);

  static DateTime? tryFromSecondsSinceEpoch(int? seconds) =>
      seconds != null ? fromSecondsSinceEpoch(seconds) : null;

  String formattedDateTimeFromSeconds(bool analogClock) =>
      '${_weekdayName(weekday)}, $formattedDate, ${formattedTime(analogClock)}';

  static DateTime? fromFuzzyDate(Map<String, dynamic>? map) {
    if (map?['year'] == null) return null;
    return DateTime(map!['year'], map['month'] ?? 1, map['day'] ?? 1);
  }

  static String? fuzzyDateString(Map<String, dynamic>? map) {
    if (map == null || map['year'] == null) return null;

    final year = map['year'];
    final month = map['month'];
    final day = map['day'];

    return '${day != null ? '$day ' : ''}'
        '${month != null ? '${monthName(month)} ' : ''}'
        '$year';
  }

  Map<String, dynamic> get fuzzyDate =>
      {'year': year, 'month': month, 'day': day};

  String get formattedWithWeekDay =>
      '$formattedDate - ${_weekdayName(weekday)}';

  String get formattedDate => '$day ${monthName(month)} $year';

  String formattedTime(bool analogClock) {
    if (analogClock) {
      final (overflows, realHour) =
          hour > 12 ? (true, hour - 12) : (false, hour);

      return '${realHour < 10 ? 0 : ''}$realHour'
          ':${minute < 10 ? 0 : ''}$minute '
          '${overflows ? 'PM' : 'AM'}';
    }

    return '${hour <= 9 ? 0 : ''}$hour'
        ':${minute <= 9 ? 0 : ''}$minute';
  }

  String get timeUntil {
    int minutes = difference(DateTime.now()).inMinutes;
    int hours = minutes ~/ 60;
    minutes %= 60;
    int days = hours ~/ 24;
    hours %= 24;
    return '${days < 1 ? "" : "${days}d "}'
        '${hours < 1 ? "" : "${hours}h "}'
        '${minutes < 1 ? "" : "${minutes}m"}';
  }

  static String monthName(int month) => switch (month) {
        1 => 'Jan',
        2 => 'Feb',
        3 => 'Mar',
        4 => 'Apr',
        5 => 'May',
        6 => 'Jun',
        7 => 'Jul',
        8 => 'Aug',
        9 => 'Sep',
        10 => 'Oct',
        11 => 'Nov',
        _ => 'Dec',
      };

  static String _weekdayName(int weekday) => switch (weekday) {
        1 => 'Mon',
        2 => 'Tue',
        3 => 'Wed',
        4 => 'Thu',
        5 => 'Fri',
        6 => 'Sat',
        _ => 'Sun',
      };
}
