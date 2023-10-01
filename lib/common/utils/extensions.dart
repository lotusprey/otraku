import 'package:flutter/material.dart';
import 'package:otraku/common/utils/options.dart';

extension StringUtil on String {
  static String? codeToCountry(String? code) => switch (code) {
        'JP' => 'Japan',
        'CN' => 'China',
        'KR' => 'South Korea',
        'TW' => 'Taiwan',
        _ => null,
      };

  static String? tryNoScreamingSnakeCase(dynamic str) =>
      str is String ? str.noScreamingSnakeCase : null;

  static final _ampersand = '&'.codeUnitAt(0);
  static final _hashtag = '#'.codeUnitAt(0);
  static final _semicolon = ';'.codeUnitAt(0);

  /// AniList can't handle some unicode characters, so before uploading text,
  /// symbols that are too big should be represented as HTML character entity
  /// references. Important primarily for emojis, hence the name.
  String get withParsedEmojis {
    final parsedRunes = <int>[];
    for (final c in runes.toList()) {
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

  String get noScreamingSnakeCase => splitMapJoin(
        '_',
        onMatch: (_) => ' ',
        onNonMatch: (s) => s[0].toUpperCase() + s.substring(1).toLowerCase(),
      );
}

extension DateTimeUtil on DateTime {
  int get secondsSinceEpoch => millisecondsSinceEpoch ~/ 1000;

  static DateTime fromSecondsSinceEpoch(int seconds) =>
      DateTime.fromMillisecondsSinceEpoch(seconds * 1000);

  static DateTime? fromFuzzyDate(Map<String, dynamic>? map) {
    if (map?['year'] == null) return null;
    return DateTime(map!['year'], map['month'] ?? 0, map['day'] ?? 0);
  }

  static DateTime? tryFromSecondsSinceEpoch(int? seconds) =>
      seconds != null ? fromSecondsSinceEpoch(seconds) : null;

  static String tryFormattedDateTimeFromSeconds(int? seconds) {
    if (seconds == null) return '';
    return fromSecondsSinceEpoch(seconds).formattedDateTime;
  }

  Map<String, dynamic> get fuzzyDate =>
      {'year': year, 'month': month, 'day': day};

  String get formattedDateTime =>
      '$formattedWeekday, $formattedDate, $formattedTime';

  String get formattedWeekday => switch (weekday) {
        1 => 'Mon',
        2 => 'Tue',
        3 => 'Wed',
        4 => 'Thu',
        5 => 'Fri',
        6 => 'Sat',
        _ => 'Sun',
      };

  String get formattedDate {
    final monthName = switch (month) {
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
    return '$day $monthName $year';
  }

  String get formattedTime {
    if (Options().analogueClock) {
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
}

extension ColorUtil on Color {
  static Color? fromHexString(String src) {
    try {
      return Color(int.parse(src.substring(1, 7), radix: 16) + 0xFF000000);
    } catch (_) {
      return null;
    }
  }
}
