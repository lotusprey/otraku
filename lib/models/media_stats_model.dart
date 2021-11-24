import 'package:otraku/constants/list_status.dart';
import 'package:otraku/utils/convert.dart';

class MediaStatsModel {
  MediaStatsModel._();

  final rankTexts = <String>[];
  final rankTypes = <bool>[];

  final scoreNames = <int>[];
  final scoreValues = <int>[];

  final statusNames = <String>[];
  final statusValues = <int>[];

  factory MediaStatsModel(Map<String, dynamic> map) {
    final model = MediaStatsModel._();

    // The key is the text and the value signals
    // if the rank is about rating or popularity.
    if (map['rankings'] != null)
      for (final rank in map['rankings']) {
        final String when = (rank['allTime'] ?? false)
            ? 'Ever'
            : rank['season'] != null
                ? '${Convert.clarifyEnum(rank['season'])} ${rank['year'] ?? ''}'
                : (rank['year'] ?? '').toString();
        if (when.isEmpty) continue;

        if (rank['type'] == 'RATED') {
          model.rankTexts.add('#${rank["rank"]} Highest Rated $when');
          model.rankTypes.add(true);
        } else {
          model.rankTexts.add('#${rank["rank"]} Most Popular $when');
          model.rankTypes.add(false);
        }
      }

    if (map['stats'] != null) {
      if (map['stats']['scoreDistribution'] != null)
        for (final s in map['stats']['scoreDistribution']) {
          model.scoreNames.add(s['score']);
          model.scoreValues.add(s['amount']);
        }

      if (map['stats']['statusDistribution'] != null)
        for (final s in map['stats']['statusDistribution']) {
          int index = -1;
          for (int i = 0; i < model.statusValues.length; i++)
            if (model.statusValues[i] < s['amount']) {
              model.statusValues.insert(i, s['amount']);
              index = i;
              break;
            }

          if (index < 0) {
            index = model.statusValues.length;
            model.statusValues.add(s['amount']);
          }

          model.statusNames.insert(
            index,
            Convert.adaptListStatus(
              Convert.strToEnum(s['status'], ListStatus.values)!,
              map['type'] == 'ANIME',
            ),
          );
        }
    }

    return model;
  }
}
