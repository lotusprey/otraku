import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'package:otraku/models/list_entry_tile_data.dart';
import 'package:otraku/providers/collection.dart';

class AnimeCollection extends Collection with ChangeNotifier {
  //Query settings
  static const String _url = 'https://graphql.anilist.co';
  final int userId;
  final String scoreFormat;
  Map<String, String> _headers;

  //Data
  bool _isLoaded = false;
  List<String> _names;
  List<List<ListEntryTileData>> _entries;

  AnimeCollection({
    @required accessToken,
    @required this.userId,
    @required this.scoreFormat,
  }) {
    _headers = {
      'Authorization': 'Bearer $accessToken',
      'Accept': 'application/json',
      'Content-type': 'application/json',
    };
  }

  @override
  String get name => 'Anime';

  @override
  bool get isLoaded => _isLoaded;

  @override
  List<String> get names => _names;

  @override
  List<List<ListEntryTileData>> get entries => _entries;

  //Set isLoaded property to false in order to reload
  void unload() => _isLoaded = false;

  //Fetch anime media list collection
  Future<void> fetchMediaListCollection(Map<String, dynamic> filters) async {
    final query = r'''
      query Collection($userId: Int, $sort: [MediaListSort], $scoreFormat: ScoreFormat) {
        MediaListCollection(userId: $userId, type: ANIME, sort: $sort) {
          lists {
            entries {
              mediaId
              progress
              score(format: $scoreFormat)
              media {
                format
                episodes
                title {
                  userPreferred
                }
                coverImage {
                  medium
                }                
              }              
            }
            name
            isCustomList
            isSplitCompletedList
            status
          }
        }
        User(id: $userId) {
          mediaListOptions {
            animeList {
              sectionOrder
            }
          }
        }
      }
    ''';

    final request = json.encode({
      'query': query,
      'variables': {
        ...filters,
        'userId': userId,
        'scoreFormat': scoreFormat,
      },
    });

    final response = await post(_url, body: request, headers: _headers);
    final result = json.decode(response.body)['data'];

    final mediaListCollection =
        result['MediaListCollection']['lists'] as List<dynamic>;

    final sectionOrder = result['User']['mediaListOptions']['animeList']
        ['sectionOrder'] as List<dynamic>;

    _names = [];
    _entries = [];

    for (final section in sectionOrder) {
      for (int i = 0; i < mediaListCollection.length; i++) {
        if (section == mediaListCollection[i]['name']) {
          final currentMediaList = mediaListCollection.removeAt(i);

          _names.add(currentMediaList['name']);

          _entries.add((currentMediaList['entries'] as List<dynamic>)
              .map((e) => ListEntryTileData(
                    id: e['mediaId'],
                    title: e['media']['title']['userPreferred'],
                    cover: e['media']['coverImage']['medium'],
                    format: e['media']['format'],
                    score: e['score'].toDouble(),
                    progress: e['progress'],
                    totalEpCount: (e['media']['episodes'] ?? '?').toString(),
                  ))
              .toList());

          break;
        }
      }
    }

    _isLoaded = true;
  }
}
