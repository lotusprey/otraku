import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:otraku/enums/enum_helper.dart';
import 'package:otraku/enums/media_list_status_enum.dart';
import 'package:otraku/models/entry_user_data.dart';

class MediaItem with ChangeNotifier {
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
            large
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
          episodes
          chapters
          mediaListEntry {
            id
            status
            progress
            score
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
        progressMax: body['episodes'] ?? body['chapters'],
      );
    }

    MediaListStatus status = stringToEnum(
        body['mediaListEntry']['status'],
        Map.fromIterable(
          MediaListStatus.values,
          key: (element) => describeEnum(element),
          value: (element) => element,
        ));

    return EntryUserData(
      mediaId: id,
      entryId: body['mediaListEntry']['id'],
      status: status,
      progress: body['mediaListEntry']['progress'],
      progressMax: body['episodes'] ?? body['chapters'],
      score: body['mediaListEntry']['score'].toDouble(),
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
