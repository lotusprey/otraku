import 'dart:convert';

import 'package:http/http.dart';
import 'package:otraku/enums/enum_helper.dart';
import 'package:otraku/enums/media_list_status_enum.dart';
import 'package:otraku/models/entry_user_data.dart';
import 'package:otraku/models/fuzzy_date.dart';
import 'package:otraku/models/tuple.dart';

class MediaItem {
  static const String _url = 'https://graphql.anilist.co';

  final Map<String, String> headers;

  MediaItem(this.headers);

  Future<Map<String, dynamic>> fetchItemData(int id) async {
    const query = r'''
      query ItemData($id: Int) {
        Media(id: $id) {
          type
          title {
            english
            romaji
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

    final response = await post(_url, body: request, headers: headers);

    return (json.decode(response.body) as Map<String, dynamic>)['data']['Media']
        as Map<String, dynamic>;
  }

  Future<EntryUserData> fetchUserData(int id) async {
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

    final result = await post(_url, body: request, headers: headers);

    final Map<String, dynamic> body =
        (json.decode(result.body) as Map<String, dynamic>)['data']['Media'];

    if (body['mediaListEntry'] == null) {
      return EntryUserData(
        mediaId: id,
        type: body['type'],
        format: body['format'],
        progressMax: body['episodes'] ?? body['chapters'],
        progressVolumesMax: body['voumes'],
        customLists: [],
      );
    }

    MediaListStatus status = stringToEnum(
      body['mediaListEntry']['status'],
      MediaListStatus.values,
    );

    final List<Tuple<String, bool>> customLists = [];
    if (body['mediaListEntry']['customLists'] != null) {
      for (final key in body['mediaListEntry']['customLists'].keys) {
        customLists.add(Tuple(key, body['mediaListEntry']['customLists'][key]));
      }
    }

    return EntryUserData(
      mediaId: id,
      entryId: body['mediaListEntry']['id'],
      type: body['type'],
      format: body['format'],
      status: status,
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

  Future<bool> toggleFavourite(int id, String entryType) async {
    entryType = entryType.toLowerCase();

    final query = '''
      mutation(\$id: Int) {
        ToggleFavourite(${entryType}Id: \$id) {
          $entryType(page: 1, perPage: 1) {
            pageInfo {
              currentPage
            }
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

    final result = await post(_url, body: request, headers: headers);
    return !(json.decode(result.body) as Map<String, dynamic>)
        .containsKey('errors');
  }
}
