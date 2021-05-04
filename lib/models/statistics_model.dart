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
    for (final f in map['formats'])
      model.formats.add(EnumStatistics(f, 'format'));
    for (final s in map['statuses'])
      model.statuses.add(EnumStatistics(s, 'status'));
    for (final c in map['countries'])
      model.countries.add(EnumStatistics(c, 'country'));
    return model;
  }
}

class NumberStatistics {
  final int count;
  final double meanScore;
  final int minutesWatched;
  final int chaptersRead;
  final int number;

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
        number: map[key],
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
