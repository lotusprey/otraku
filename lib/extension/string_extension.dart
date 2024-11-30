import 'package:otraku/extension/date_time_extension.dart';

extension StringExtension on String {
  static String? languageToCode(String? language) => switch (language) {
        'Japanese' => 'JP',
        'Chinese' => 'CN',
        'Korean' => 'KR',
        'French' => 'FR',
        'Spanish' => 'ES',
        'Italian' => 'IT',
        'Portuguese' => 'PT',
        'German' => 'DE',
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

  static String? fromFuzzyDate(Map<String, dynamic>? map) {
    if (map?['year'] == null) return null;
    final year = map!['year'];
    final month = map['month'];
    final day = map['day'];
    return '${day != null ? '$day ' : ''}${month != null ? '${DateTimeExtension.monthName(month)} ' : ''}$year';
  }
}
