import 'package:flutter/material.dart';
import 'package:otraku/enums/enum_helper.dart';
import 'package:otraku/models/tuple.dart';
import 'package:provider/provider.dart';
import 'package:otraku/providers/media_item.dart';
import 'package:otraku/enums/media_list_status_enum.dart';

class MediaItemData {
  int id;
  String type;
  String title;
  int nextEpisode;
  String timeUntilAiring;
  int popularity;
  int favourites;
  Image cover;
  Image banner;
  bool isFavourite;
  MediaListStatus mediaListStatus;
  String description;
  List<Tuple> info = [];

  MediaItemData({
    @required BuildContext context,
    @required Function setState,
    @required int mediaId,
  }) {
    id = mediaId;

    Provider.of<MediaItem>(context, listen: false).fetchData(id).then((data) {
      //General
      title = data['title']['english'] ?? data['title']['romaji'];
      type = data['type'];

      if (data['nextAiringEpisode'] != null) {
        nextEpisode = data['nextAiringEpisode']['episode'];

        int minutes = data['nextAiringEpisode']['timeUntilAiring'] ~/ 60;
        int hours = minutes ~/ 60;
        minutes %= 60;
        int days = hours ~/ 24;
        hours %= 24;

        timeUntilAiring = '${days}d ${hours}h ${minutes}m';
      }

      popularity = data['popularity'];
      favourites = data['favourites'];

      //User Data
      isFavourite = data['isFavourite'];

      if (data['mediaListEntry'] != null) {
        mediaListStatus = getMediaListStatusFromString(
            data['mediaListEntry']['status'], data['type']);
      } else {
        mediaListStatus = MediaListStatus.None;
      }

      //Images
      if (data['bannerImage'] != null) {
        banner = Image.network(
          data['bannerImage'],
          fit: BoxFit.cover,
        );
      }

      cover = Image.network(
        data['coverImage']['extraLarge'] ?? data['coverImage']['large'],
        fit: BoxFit.cover,
      );
      precacheImage(cover.image, context);

      //Description
      final String desc = data['description'];
      if (desc != null) {
        description = desc.replaceAll(RegExp(r'<[^>]*>'), '');
      }

      //Info

      //Format
      if (data['format'] != null) {
        info.add(Tuple('Format', clarifyEnum(data['format'])));
      }

      //Status
      if (data['status'] != null) {
        info.add(Tuple('Status', clarifyEnum(data['status'])));
      }

      //Episodes
      if (data['episodes'] != null) {
        info.add(Tuple('Episodes', data['episodes'].toString()));
      }

      //Duration
      if (data['duration'] != null) {
        int time = data['duration'];
        int hours = time ~/ 60;
        int minutes = time % 60;
        String duration =
            (hours != 0 ? '$hours hours, ' : '') + '$minutes mins';
        info.add(Tuple('Episode duration', duration));
      }

      //Chapters
      if (data['chapters'] != null) {
        info.add(Tuple('Chapters', data['chapters'].toString()));
      }

      //Volumes
      if (data['volumes'] != null) {
        info.add(Tuple('Volumes', data['volumes'].toString()));
      }

      //Average Score
      if (data['averageScore'] != null) {
        info.add(Tuple('Average Score', '${data["averageScore"]}%'));
      }

      //Mean Score
      if (data['meanScore'] != null) {
        info.add(Tuple('Mean Score', '${data["meanScore"]}%'));
      }

      //Start Date
      String startDate = _date(data['startDate']);
      if (startDate != null) {
        info.add(Tuple('Start Date', startDate));
      }

      //End Date
      String endDate = _date(data['endDate']);
      if (endDate != null) {
        info.add(Tuple('End Date', endDate));
      }

      //Season
      if (data['season'] != null) {
        String season = data['season'];
        season = season[0] + season.substring(1).toLowerCase();
        if (data['seasonYear'] != null) {
          season += ' ${data["seasonYear"]}';
        }
        info.add(Tuple('Season', season));
      }

      //Studios
      //Producers
      if (data['studios'] != null) {
        final List<String> studios = [];
        final List<String> producers = [];
        final List<dynamic> companies = data['studios']['edges'];

        for (Map<String, dynamic> company in companies) {
          if (company['isMain']) {
            studios.add(company['node']['name']);
          } else {
            producers.add(company['node']['name']);
          }
        }

        if (studios.length > 0) {
          if (studios.length > 2) {
            int middleOfStudioList = (studios.length / 2).floor();
            var studioString =
                studios.sublist(0, middleOfStudioList).join(', ') +
                    '\n' +
                    studios.sublist(middleOfStudioList).join(', ');
            info.add(Tuple('Studios', studioString));
          } else {
            info.add(Tuple('Studios', studios.join('\n')));
          }
        }

        if (producers.length > 0) {
          if (producers.length > 2) {
            int middleOfProducerList = (producers.length / 2).floor();
            var producerString =
                producers.sublist(0, middleOfProducerList).join(', ') +
                    '\n' +
                    producers.sublist(middleOfProducerList).join(', ');
            info.add(Tuple('Producers', producerString));
          } else {
            info.add(Tuple('Producers', producers.join('\n')));
          }
        }
      }

      //Country of Origin
      if (data['countryOfOrigin'] != null) {
        info.add(Tuple('Country of Origin', data['countryOfOrigin']));
      }

      setState();
    });
  }

  Future<void> toggleFavourite(BuildContext context) async {
    final didToggle = await Provider.of<MediaItem>(context, listen: false)
        .toggleFavourite(id, type);
    if (didToggle) {
      isFavourite = !isFavourite;
    }
  }

  String _date(Map<String, dynamic> data) {
    if (data['year'] == null) {
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
    };

    String month = months[data['month'] as int];
    var day = data['day'] ?? '';

    return '$month $day, ${data['year']}';
  }
}
