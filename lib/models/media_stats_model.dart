import 'package:otraku/enums/list_status.dart';
import 'package:otraku/utils/convert.dart';

class MediaStatsModel {
  MediaStatsModel._();

  final ranks = <String, bool>{};
  final scores = <int, int>{};
  final statuses = <String, int>{};

  factory MediaStatsModel(Map<String, dynamic> map) {
    final model = MediaStatsModel._();

    // The key is the text and the value signals
    // if the rank is about rating or popularity.
    if (map['rankings'] != null)
      for (final rank in map['rankings']) {
        final String when = (rank['allTime'] ?? false)
            ? 'Ever'
            : (rank['year'] ?? rank['season'] ?? '').toString();
        if (when.isEmpty) continue;

        if (rank['type'] == 'RATED')
          model.ranks['#${rank["rank"]} Highest Rated $when'] = true;
        else
          model.ranks['#${rank["rank"]} Most Popular $when'] = false;
      }

    if (map['stats'] != null) {
      if (map['stats']['scoreDistribution'] != null)
        for (final s in map['stats']['scoreDistribution'])
          model.scores[s['score']] = s['amount'];

      if (map['stats']['statusDistribution'] != null) {
        final keys = <String>[];
        final values = <int>[];

        for (final s in map['stats']['statusDistribution']) {
          int index = -1;
          for (int i = 0; i < values.length; i++)
            if (values[i] < s['amount']) {
              values.insert(i, s['amount']);
              index = i;
              break;
            }

          if (index < 0) {
            index = values.length;
            values.add(s['amount']);
          }

          keys.insert(
            index,
            Convert.adaptListStatus(
              Convert.strToEnum(s['status'], ListStatus.values)!,
              map['type'] == 'ANIME',
            ),
          );
        }

        for (int i = 0; i < keys.length; i++)
          model.statuses[keys[i]] = values[i];
      }
    }

    return model;
  }
}
