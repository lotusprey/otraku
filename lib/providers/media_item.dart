import 'dart:convert';

import 'package:http/http.dart';
import 'package:otraku/enums/enum_helper.dart';
import 'package:otraku/enums/media_list_status_enum.dart';
import 'package:otraku/models/page_data/entry_data.dart';
import 'package:otraku/models/fuzzy_date.dart';
import 'package:otraku/models/page_data/media_data.dart';
import 'package:otraku/models/tuple.dart';

class MediaItem {
  static const String _url = 'https://graphql.anilist.co';

  final Map<String, String> _headers;

  MediaItem(this._headers);

  Future<MediaData> fetchItemData(int id) async {
    const query = r'''
      query Media($id: Int) {
        Media(id: $id) {
          type
          title {
            userPreferred
            english
            romaji
            native
          }
          nextAiringEpisode {
            airingAt
          }
          coverImage {
            extraLarge
          }
          bannerImage
          isFavourite
          popularity
          favourites
          nextAiringEpisode {
            episode
            timeUntilAiring
          }
          mediaListEntry {
            status
          }
          description
          format
          status
          episodes
          duration
          chapters
          volumes
          season
          seasonYear
          source
          hashtag
          countryOfOrigin
          startDate {
            year
            month
            day
          }
          endDate {
            year
            month
            day
          }
          averageScore
          meanScore
          studios {
            edges {
              node {
                name
              }
              isMain
            }
          }
        }
      }
    ''';

    final Map<String, int> variables = {
      'id': id,
    };

    final request = json.encode({
      'query': query,
      'variables': variables,
    });

    final response = await post(_url, body: request, headers: _headers);

    return MediaData(
      id,
      (json.decode(response.body) as Map<String, dynamic>)['data']['Media']
          as Map<String, dynamic>,
    );
  }

  Future<EntryData> fetchUserData(int id) async {
    final query = r'''
      query ItemUserData($id: Int) {
        Media(id: $id) {
          type
          format
          episodes
          chapters
          volumes
          mediaListEntry {
            id
            status
            progress
            progressVolumes
            score
            repeat
            notes
            startedAt {
              year
              month
              day
            }
            completedAt {
              year
              month
              day
            }
            private
            hiddenFromStatusLists
            customLists
          }
        }
      }
    ''';

    final Map<String, Object> variables = {
      'id': id,
    };

    final request = json.encode({
      'query': query,
      'variables': variables,
    });

    final result = await post(_url, body: request, headers: _headers);

    final Map<String, dynamic> body =
        (json.decode(result.body) as Map<String, dynamic>)['data']['Media'];

    if (body['mediaListEntry'] == null) {
      return EntryData(
        mediaId: id,
        type: body['type'],
        format: body['format'],
        progressMax: body['episodes'] ?? body['chapters'],
        progressVolumesMax: body['voumes'],
        customLists: [],
      );
    }

    final List<Tuple<String, bool>> customLists = [];
    if (body['mediaListEntry']['customLists'] != null) {
      for (final key in body['mediaListEntry']['customLists'].keys) {
        customLists.add(Tuple(key, body['mediaListEntry']['customLists'][key]));
      }
    }

    return EntryData(
      mediaId: id,
      entryId: body['mediaListEntry']['id'],
      type: body['type'],
      format: body['format'],
      status: stringToEnum(
        body['mediaListEntry']['status'],
        MediaListStatus.values,
      ),
      progress: body['mediaListEntry']['progress'] ?? 0,
      progressMax: body['episodes'] ?? body['chapters'],
      progressVolumes: body['mediaListEntry']['volumes'] ?? 0,
      progressVolumesMax: body['voumes'],
      score: body['mediaListEntry']['score'].toDouble(),
      repeat: body['mediaListEntry']['repeat'],
      notes: body['mediaListEntry']['notes'],
      startDate: mapToDateTime(body['mediaListEntry']['startedAt']),
      endDate: mapToDateTime(body['mediaListEntry']['completedAt']),
      private: body['mediaListEntry']['private'],
      hiddenFromStatusLists: body['mediaListEntry']['hiddenFromStatusLists'],
      customLists: customLists,
    );
  }
}
