class StatisticsModel {
  final int count;
  final double meanScore;
  final double standardDeviation;
  final int minutesWatched;
  final int episodesWatched;
  final int chaptersRead;
  final int volumesRead;
  final scores = <ScoreStatistics>[];

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
    final s = StatisticsModel._(
      count: map['count'],
      meanScore: map['meanScore'].toDouble(),
      standardDeviation: map['standardDeviation'].toDouble(),
      minutesWatched: map['minutesWatched'],
      episodesWatched: map['episodesWatched'],
      chaptersRead: map['chaptersRead'],
      volumesRead: map['volumesRead'],
    );
    for (final score in map['scores']) s.scores.add(ScoreStatistics(score));
    return s;
  }
}

class ScoreStatistics {
  final int count;
  final double meanScore;
  final int minutesWatched;
  final int chaptersRead;
  final int score;

  ScoreStatistics._({
    required this.count,
    required this.meanScore,
    required this.minutesWatched,
    required this.chaptersRead,
    required this.score,
  });

  factory ScoreStatistics(Map<String, dynamic> map) => ScoreStatistics._(
        count: map['count'],
        meanScore: map['meanScore'].toDouble(),
        minutesWatched: map['minutesWatched'],
        chaptersRead: map['chaptersRead'],
        score: map['score'],
      );
}
