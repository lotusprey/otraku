import 'package:otraku/feature/collection/collection_models.dart';
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
    final scores = <ScoreStatistic>[];
    final lengths = <LengthStatistic>[];
    final formats = <FormatStatistic>[];
    final statuses = <StatusStatistic>[];
    final countries = <CountryStatistic>[];

    for (final m in map['scores']) {
      scores.add((
        count: m['count'],
        meanScore: m['meanScore'].toDouble(),
        amount: ofAnime ? m['minutesWatched'] ~/ 60 : m['chaptersRead'],
        name: m['score']?.toString() ?? '?',
      ));
    }
    for (final m in map['lengths']) {
      lengths.add((
        count: m['count'],
        meanScore: m['meanScore'].toDouble(),
        amount: ofAnime ? m['minutesWatched'] ~/ 60 : m['chaptersRead'],
        name: m['length']?.toString() ?? '?',
      ));
    }
    for (final m in map['formats']) {
      formats.add((
        count: m['count'],
        meanScore: m['meanScore'].toDouble(),
        amount: ofAnime ? m['minutesWatched'] ~/ 60 : m['chaptersRead'],
        name: MediaFormat.from(m['format'])!,
      ));
    }
    for (final m in map['statuses']) {
      statuses.add((
        count: m['count'],
        meanScore: m['meanScore'].toDouble(),
        amount: ofAnime ? m['minutesWatched'] ~/ 60 : m['chaptersRead'],
        name: ListStatus.from(m['status'])!,
      ));
    }
    for (final m in map['countries']) {
      countries.add((
        count: m['count'],
        meanScore: m['meanScore'].toDouble(),
        amount: ofAnime ? m['minutesWatched'] ~/ 60 : m['chaptersRead'],
        name: OriginCountry.fromCode(m['country'])!,
      ));
    }

    // The backend can't sort them by length, so it has to be done locally.
    lengths.sort((a, b) {
      if (a.name == '?') return 1;
      if (b.name == '?') return -1;

      if (a.name[a.name.length - 1] == '+') return 1;
      if (b.name[b.name.length - 1] == '+') return -1;

      if (a.name.length > b.name.length) return 1;
      if (a.name.length < b.name.length) return -1;

      return a.name.compareTo(b.name);
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
  final List<ScoreStatistic> scores;
  final List<LengthStatistic> lengths;
  final List<FormatStatistic> formats;
  final List<StatusStatistic> statuses;
  final List<CountryStatistic> countries;
}

typedef ScoreStatistic = ({int count, double meanScore, int amount, String name});

typedef LengthStatistic = ({int count, double meanScore, int amount, String name});

typedef FormatStatistic = ({int count, double meanScore, int amount, MediaFormat name});

typedef StatusStatistic = ({int count, double meanScore, int amount, ListStatus name});

typedef CountryStatistic = ({int count, double meanScore, int amount, OriginCountry name});
