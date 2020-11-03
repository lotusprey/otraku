import 'package:flutter/material.dart';
import 'package:otraku/enums/browsable_enum.dart';
import 'package:otraku/enums/enum_helper.dart';
import 'package:otraku/models/date_time_mapping.dart';
import 'package:otraku/models/page_data/page_item_data.dart';
import 'package:otraku/models/tuple.dart';
import 'package:otraku/enums/media_list_status_enum.dart';

class Media extends PageItemData {
  String type;
  String title;
  int nextEpisode;
  String timeUntilAiring;
  Image cover;
  Image banner;
  MediaListStatus status;
  String description;
  List<Tuple> info = [];

  Media(int id, Map<String, dynamic> data)
      : super(
          id: id,
          isFavourite: data['isFavourite'],
          favourites: data['favourites'],
          browsable:
              data['type'] == 'ANIME' ? Browsable.anime : Browsable.manga,
        ) {
    //General
    title = data['title']['userPreferred'];
    type = data['type'];

    if (data['nextAiringEpisode'] != null) {
      nextEpisode = data['nextAiringEpisode']['episode'];

      timeUntilAiring =
          secondsToTime(data['nextAiringEpisode']['timeUntilAiring']);
    }

    //User Data

    if (data['mediaListEntry'] != null) {
      status = stringToEnum(
        data['mediaListEntry']['status'].toString(),
        MediaListStatus.values,
      );
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
      String duration = (hours != 0 ? '$hours hours, ' : '') + '$minutes mins';
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

    //Popularity
    if (data['popularity'] != null) {
      info.add(Tuple('Popularity', '${data['popularity']}'));
    }

    //Start Date
    String startDate = mapToDateString(data['startDate']);
    if (startDate != null) {
      info.add(Tuple('Start Date', startDate));
    }

    //End Date
    String endDate = mapToDateString(data['endDate']);
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

    //Source
    if (data['source'] != null) {
      info.add(Tuple('Source', clarifyEnum(data['source'])));
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
          var studioString = studios.sublist(0, middleOfStudioList).join(', ') +
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

    //English Title
    if (data['title']['english'] != null) {
      info.add(Tuple('English', data['title']['english']));
    }

    //Romaji Title
    if (data['title']['romaji'] != null) {
      info.add(Tuple('Romaji', data['title']['romaji']));
    }

    //Native Title
    if (data['title']['native'] != null) {
      info.add(Tuple('Native', data['title']['native']));
    }

    //Hashtag
    if (data['hashtag'] != null) {
      info.add(Tuple('Hashtag', data['hashtag']));
    }

    //Country of Origin
    if (data['countryOfOrigin'] != null) {
      info.add(Tuple('Origin', data['countryOfOrigin']));
    }
  }
}
