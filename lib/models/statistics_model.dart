import 'package:otraku/utils/convert.dart';

class StatisticsModel {
  final int count;
  final double meanScore;
  final double standardDeviation;
  final int minutesWatched;
  final int episodesWatched;
  final int chaptersRead;
  final int volumesRead;
  final scores = <NumberStatistics>[];
  final lengths = <NumberStatistics>[];
  final formats = <EnumStatistics>[];
  final statuses = <EnumStatistics>[];
  final countries = <EnumStatistics>[];

  StatisticsModel._({
    required this.count,
    required this.meanScore,
    required this.standardDeviation,
    required this.minutesWatched,
    required this.episodesWatched,
    required this.chaptersRead,
    required this.volumesRead,
  });

  factory StatisticsModel(Map<String, dynamic> map) {
    final model = StatisticsModel._(
      count: map['count'],
      meanScore: map['meanScore'].toDouble(),
      standardDeviation: map['standardDeviation'].toDouble(),
      minutesWatched: map['minutesWatched'],
      episodesWatched: map['episodesWatched'],
      chaptersRead: map['chaptersRead'],
      volumesRead: map['volumesRead'],
    );
    for (final s in map['scores'])
      model.scores.add(NumberStatistics(s, 'score'));
    for (final l in map['lengths'])
      model.lengths.add(NumberStatistics(l, 'length'));
    for (final f in map['formats'])
      model.formats.add(EnumStatistics(f, 'format'));
    for (final s in map['statuses'])
      model.statuses.add(EnumStatistics(s, 'status'));
    for (final c in map['countries']) {
      c['country'] = Convert.COUNTRY_CODES[c['country']];
      model.countries.add(EnumStatistics(c, 'country'));
    }

    // The backend can't sort them by length, so it has to be done locally.
    model.lengths.sort((a, b) {
      if (a.number == '?') return 1;
      if (b.number == '?') return -1;

      if (a.number[a.number.length - 1] == '+') return 1;
      if (b.number[b.number.length - 1] == '+') return -1;

      if (a.number.length > b.number.length) return 1;
      if (a.number.length < b.number.length) return -1;

      return a.number.compareTo(b.number);
    });

    return model;
  }
}

class NumberStatistics {
  final int count;
  final double meanScore;
  final int minutesWatched;
  final int chaptersRead;
  final String number;

  NumberStatistics._({
    required this.count,
    required this.meanScore,
    required this.minutesWatched,
    required this.chaptersRead,
    required this.number,
  });

  factory NumberStatistics(Map<String, dynamic> map, String key) =>
      NumberStatistics._(
        count: map['count'],
        meanScore: map['meanScore'].toDouble(),
        minutesWatched: map['minutesWatched'],
        chaptersRead: map['chaptersRead'],
        number: (map[key] ?? '?').toString(),
      );
}

class EnumStatistics {
  final int count;
  final double meanScore;
  final int minutesWatched;
  final int chaptersRead;
  final String value;

  EnumStatistics._({
    required this.count,
    required this.meanScore,
    required this.minutesWatched,
    required this.chaptersRead,
    required this.value,
  });

  factory EnumStatistics(Map<String, dynamic> map, String key) =>
      EnumStatistics._(
        count: map['count'],
        meanScore: map['meanScore'].toDouble(),
        minutesWatched: map['minutesWatched'],
        chaptersRead: map['chaptersRead'],
        value: Convert.clarifyEnum(map[key])!,
      );
}
