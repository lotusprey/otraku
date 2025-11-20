import 'package:otraku/extension/string_extension.dart';
import 'package:otraku/feature/media/media_models.dart';

class Statistics {
  Statistics._({
    required this.count,
    required this.meanScore,
    required this.standardDeviation,
    required this.partsConsumed,
    required this.amountConsumed,
    required this.scores,
    required this.lengths,
    required this.formats,
    required this.statuses,
    required this.countries,
  });

  factory Statistics(Map<String, dynamic> map, bool ofAnime) {
    final scores = <AmountStatistics>[];
    final lengths = <AmountStatistics>[];
    final formats = <TypeStatistics>[];
    final statuses = <TypeStatistics>[];
    final countries = <TypeStatistics>[];

    for (final s in map['scores']) {
      scores.add(AmountStatistics(s, 'score', ofAnime));
    }
    for (final l in map['lengths']) {
      lengths.add(AmountStatistics(l, 'length', ofAnime));
    }
    for (final f in map['formats']) {
      formats.add(TypeStatistics(f, 'format'));
    }
    for (final s in map['statuses']) {
      statuses.add(TypeStatistics(s, 'status'));
    }
    for (final c in map['countries']) {
      c['country'] = OriginCountry.fromCode(c['country'])?.label;
      countries.add(TypeStatistics(c, 'country'));
    }

    // The backend can't sort them by length, so it has to be done locally.
    lengths.sort((a, b) {
      if (a.type == '?') return 1;
      if (b.type == '?') return -1;

      if (a.type[a.type.length - 1] == '+') return 1;
      if (b.type[b.type.length - 1] == '+') return -1;

      if (a.type.length > b.type.length) return 1;
      if (a.type.length < b.type.length) return -1;

      return a.type.compareTo(b.type);
    });

    return Statistics._(
      count: map['count'],
      meanScore: map['meanScore'].toDouble(),
      standardDeviation: map['standardDeviation'].toDouble(),
      partsConsumed: ofAnime ? map['episodesWatched'] : map['chaptersRead'],
      amountConsumed: ofAnime ? map['minutesWatched'] : map['volumesRead'],
      scores: scores,
      lengths: lengths,
      formats: formats,
      statuses: statuses,
      countries: countries,
    );
  }

  final int count;
  final double meanScore;
  final double standardDeviation;
  final int partsConsumed;
  final int amountConsumed;
  final List<AmountStatistics> scores;
  final List<AmountStatistics> lengths;
  final List<TypeStatistics> formats;
  final List<TypeStatistics> statuses;
  final List<TypeStatistics> countries;
}

class AmountStatistics {
  AmountStatistics._({
    required this.count,
    required this.meanScore,
    required this.amount,
    required this.type,
  });

  factory AmountStatistics(Map<String, dynamic> map, String key, bool ofAnime) =>
      AmountStatistics._(
        count: map['count'],
        meanScore: map['meanScore'].toDouble(),
        amount: ofAnime ? map['minutesWatched'] ~/ 60 : map['chaptersRead'],
        type: (map[key] ?? '?').toString(),
      );

  final int count;
  final double meanScore;
  final int amount;
  final String type;
}

class TypeStatistics {
  TypeStatistics._({
    required this.count,
    required this.meanScore,
    required this.hoursWatched,
    required this.chaptersRead,
    required this.value,
  });

  factory TypeStatistics(Map<String, dynamic> map, String key) => TypeStatistics._(
    count: map['count'],
    meanScore: map['meanScore'].toDouble(),
    hoursWatched: map['minutesWatched'] ~/ 60,
    chaptersRead: map['chaptersRead'],
    value: (map[key] as String).noScreamingSnakeCase,
  );

  final int count;
  final double meanScore;
  final int hoursWatched;
  final int chaptersRead;
  final String value;
}
