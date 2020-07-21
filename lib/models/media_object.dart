import 'dart:async';

import 'package:flutter/material.dart';
import 'package:otraku/enums/media_list_status_enum.dart';
import 'package:otraku/models/tuple.dart';
import 'package:otraku/providers/single_media.dart';
import 'package:provider/provider.dart';

class MediaObject {
  int id;
  String type;
  String title;
  int nextEpisode;
  String timeUntilAiring;
  Image cover;
  Image banner;
  bool isFavourite;
  MediaListStatus mediaListStatus;
  _OverviewData overview;

  MediaObject({
    @required BuildContext context,
    @required Function setState,
    @required int mediaId,
  }) {
    id = mediaId;

    Provider.of<SingleMedia>(context, listen: false).fetchMain(id).then((data) {
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

      setState();
    });
  }

  Future<void> initOverview(BuildContext context, Function setState) async {
    overview = _OverviewData(context, id, setState);
  }

  Future<void> toggleFavourite(BuildContext context) async {
    final didToggle = await Provider.of<SingleMedia>(context, listen: false)
        .toggleFavourite(id, type);
    if (didToggle) {
      isFavourite = !isFavourite;
    }
  }
}

class _OverviewData {
  String description;
  List<Tuple> info = [];

  _OverviewData(BuildContext context, int id, Function setState) {
    Provider.of<SingleMedia>(context, listen: false)
        .fetchOverview(id)
        .then((data) {
      //Description
      final String desc = data['description'];
      if (desc != null) {
        description = desc.replaceAll(RegExp(r'<[^>]*>'), '');
      }

      //Format
      if (data['format'] != null) {
        info.add(Tuple('Format', _clarifyEnum(data['format'])));
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

      //Status
      if (data['status'] != null) {
        info.add(Tuple('Status', _clarifyEnum(data['status'])));
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
          info.add(Tuple('Studios', studios.join('\n')));
        }

        if (producers.length > 0) {
          info.add(Tuple('Producers', producers.join('\n')));
        }
      }

      //Country of Origin
      if (data['countryOfOrigin'] != null) {
        info.add(Tuple('Country of Origin', data['countryOfOrigin']));
      }

      setState();
    });
  }

  String _clarifyEnum(String text) {
    return text.splitMapJoin(
      '_',
      onMatch: (_) => ' ',
      onNonMatch: (s) => s[0] + s.substring(1).toLowerCase(),
    );
  }

  String _date(Map<String, dynamic> data) {
    if (data['year'] == null) {
      return null;
    }

    String month = '';
    switch (data['month'] as int) {
      case 1:
        month = 'Jan';
        break;
      case 2:
        month = 'Feb';
        break;
      case 3:
        month = 'Mar';
        break;
      case 4:
        month = 'Apr';
        break;
      case 5:
        month = 'May';
        break;
      case 6:
        month = 'Jun';
        break;
      case 7:
        month = 'Jul';
        break;
      case 8:
        month = 'Aug';
        break;
      case 9:
        month = 'Sep';
        break;
      case 10:
        month = 'Oct';
        break;
      case 11:
        month = 'Nov';
        break;
      case 12:
        month = 'Dec';
        break;
      default:
        break;
    }

    var day = data['day'] ?? '';

    return '$month $day, ${data['year']}';
  }
}
