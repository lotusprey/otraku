import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'package:otraku/models/list_entry.dart';
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
  List<List<ListEntry>> _entries;

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
  List<List<ListEntry>> get entries => _entries;

  void unload() => _isLoaded = false;

  //Fetch anime media list collection
  Future<void> fetchMediaListCollection() async {
    final query = '''
      query Collection {
        MediaListCollection(userId: $userId, type: ANIME, sort: SCORE_DESC) {
          lists {
            entries {
              mediaId
              media {
                format
                title {
                  userPreferred
                }
                coverImage {
                  medium
                }
              }
              score(format: $scoreFormat)
            }
            name
            isCustomList
            isSplitCompletedList
            status
          }
        }
      }
    ''';

    final request = json.encode({
      'query': query,
    });

    final response = await post(_url, body: request, headers: _headers);

    final result = json.decode(response.body)['data']['MediaListCollection']
        ['lists'] as List<dynamic>;

    _names = [];
    _entries = [];

    for (int i = 0; i < result.length; i++) {
      _names.add(result[i]['name']);

      _entries.add((result[i]['entries'] as List<dynamic>)
          .map((e) => ListEntry(
                id: e['mediaId'],
                title: e['media']['title']['userPreferred'],
                cover: e['media']['coverImage']['medium'],
                format: e['media']['format'],
                score: e['score'].toDouble(),
              ))
          .toList());
    }

    _isLoaded = true;
  }
}
