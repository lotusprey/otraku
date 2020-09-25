String mapToDateString(Map<String, dynamic> map) {
  if (map['year'] == null) {
    return null;
  }

  const months = {
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

  String month = months[map['month']];
  var day = map['day'] ?? '';

  return '$month $day, ${map['year']}';
}

DateTime mapToDateTime(Map<String, dynamic> map) {
  if (map['year'] == null || map['month'] == null || map['day'] == null) {
    return null;
  }

  return DateTime(map['year'], map['month'], map['day']);
}

Map<String, int> dateTimeToMap(DateTime date) {
  if (date == null) return null;

  return {
    'year': date.year,
    'month': date.month,
    'day': date.day,
  };
}
