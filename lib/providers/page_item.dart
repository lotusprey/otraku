import 'dart:convert';

import 'package:http/http.dart';
import 'package:otraku/enums/browsable_enum.dart';
import 'package:otraku/enums/enum_helper.dart';
import 'package:otraku/models/page_data/person_data.dart';
import 'package:otraku/models/page_data/studio_data.dart';
import 'package:otraku/models/sample_data/browse_result.dart';
import 'package:otraku/models/sample_data/connection.dart';
import 'package:otraku/models/tuple.dart';

class PageItem {
  static const String _url = 'https://graphql.anilist.co';

  final Map<String, String> _headers;

  PageItem(this._headers);

  Future<bool> toggleFavourite(int id, Browsable browsable) async {
    String idName = const {
      Browsable.anime: 'anime',
      Browsable.manga: 'manga',
      Browsable.characters: 'character',
      Browsable.staff: 'staff',
      Browsable.studios: 'studio',
    }[browsable];

    String pageName = const {
      Browsable.anime: 'anime',
      Browsable.manga: 'manga',
      Browsable.characters: 'characters',
      Browsable.staff: 'staff',
      Browsable.studios: 'studios',
    }[browsable];

    final query = '''
      mutation(\$id: Int) {
        ToggleFavourite(${idName}Id: \$id) {
          $pageName(page: 1, perPage: 1) {
            pageInfo {
              currentPage
            }
          }
        }
      }
    ''';

    final request = json.encode({
      'query': query,
      'variables': {'id': id},
    });

    final result = await post(_url, body: request, headers: _headers);
    return !(json.decode(result.body) as Map<String, dynamic>)
        .containsKey('errors');
  }

  Future<PersonData> fetchCharacter(int id) async {
    const query = r'''
      query Character($id: Int) {
        Character(id: $id) {
          name{full native alternative}
          image{large}
          favourites 
          isFavourite
          description(asHtml: true)
          media
          {
            edges
            {
              characterRole 
              voiceActors
              {
                id 
                name{full}
                image{large}
                language
              }
              node
              {
                id
                title{userPreferred}
                coverImage{large}
              }
            }
          }
        }
      }
    ''';

    final request = json.encode({
      'query': query,
      'variables': {'id': id},
    });

    final result = await post(_url, body: request, headers: _headers);

    final data = json.decode(result.body)['data']['Character'];

    List<Connection> primaryConnections = [];
    List<Connection> secondaryConnections = [];
    for (final connection in data['media']['edges']) {
      List<Connection> voiceActors = [];
      for (final actor in connection['voiceActors']) {
        voiceActors.add(Connection(
          id: actor['id'],
          title: actor['name']['full'],
          imageUrl: actor['image']['large'],
          text: clarifyEnum(actor['language']),
          browsable: Browsable.staff,
        ));
      }

      if (voiceActors.length == 0) {
        secondaryConnections.add(Connection(
          text: clarifyEnum(connection['characterRole']),
          id: connection['node']['id'],
          title: connection['node']['title']['userPreferred'],
          imageUrl: connection['node']['coverImage']['large'],
          browsable: connection['node']['type'] == 'ANIME'
              ? Browsable.anime
              : Browsable.manga,
        ));
      } else {
        primaryConnections.add(Connection(
          text: clarifyEnum(connection['characterRole']),
          others: voiceActors,
          id: connection['node']['id'],
          title: connection['node']['title']['userPreferred'],
          imageUrl: connection['node']['coverImage']['large'],
          browsable: connection['node']['type'] == 'ANIME'
              ? Browsable.anime
              : Browsable.manga,
        ));
      }
    }

    return PersonData(
      id: id,
      fullName: data['name']['full'],
      altNames: (data['name']['alternative'] as List<dynamic>)
          .map((a) => a.toString())
          .toList()
            ..insert(0, data['name']['native'].toString()),
      imageUrl: data['image']['large'],
      description:
          data['description'].toString().replaceAll(RegExp(r'<[^>]*>'), ''),
      isFavourite: data['isFavourite'],
      favourites: data['favourites'],
      browsable: Browsable.characters,
      primaryConnections: primaryConnections,
      secondaryConnections: secondaryConnections,
    );
  }

  Future<PersonData> fetchStaff(int id) async {
    const query = r'''
      query Staff($id: Int) {
        Staff(id: $id) {
          name{full native alternative}
          image{large}
          favourites
          isFavourite
          description(asHtml: true)
          characters {
            edges {
              role
              media {
                id
                type
                title {userPreferred}
                coverImage {large}
              }
              node {
                id
                name {full}
                image {large}
              }
            }
          }
          staffMedia {
            edges {
              staffRole
              node {
                id
                type
                title {userPreferred}
                coverImage {large}
              }
            }
          }
        }
      }
    ''';

    final request = json.encode({
      'query': query,
      'variables': {'id': id},
    });

    final result = await post(_url, body: request, headers: _headers);

    final data = json.decode(result.body)['data']['Staff'];

    List<Connection> primaryConnections = [];
    for (final connection in data['characters']['edges']) {
      primaryConnections.add(Connection(
        id: connection['media'][0]['id'],
        title: connection['media'][0]['title']['userPreferred'],
        imageUrl: connection['media'][0]['coverImage']['large'],
        browsable: connection['media'][0]['type'] == 'ANIME'
            ? Browsable.anime
            : Browsable.manga,
        others: [
          Connection(
            id: connection['node']['id'],
            title: connection['node']['name']['full'],
            text: clarifyEnum(connection['role']),
            imageUrl: connection['node']['image']['large'],
            browsable: Browsable.characters,
          ),
        ],
      ));
    }

    List<Connection> secondaryConnections = [];
    for (final connection in data['staffMedia']['edges']) {
      secondaryConnections.add(Connection(
        id: connection['node']['id'],
        title: connection['node']['title']['userPreferred'],
        text: connection['staffRole'],
        imageUrl: connection['node']['coverImage']['large'],
        browsable: connection['node']['type'] == 'ANIME'
            ? Browsable.anime
            : Browsable.manga,
      ));
    }

    return PersonData(
      id: id,
      fullName: data['name']['full'],
      altNames: (data['name']['alternative'] as List<dynamic>)
          .map((a) => a.toString())
          .toList()
            ..insert(0, data['name']['native'].toString()),
      imageUrl: data['image']['large'],
      description:
          data['description'].toString().replaceAll(RegExp(r'<[^>]*>'), ''),
      isFavourite: data['isFavourite'],
      favourites: data['favourites'],
      browsable: Browsable.staff,
      primaryConnections: primaryConnections,
      secondaryConnections: secondaryConnections,
    );
  }

  Future<StudioData> fetchStudio(int id) async {
    const query = r'''
      query Studio($id: Int) {
        Studio(id: $id) {
          name
          favourites 
          isFavourite
          media(sort: START_DATE_DESC) {
            nodes {
              id
              title {userPreferred}
              coverImage {large}
              seasonYear
            }
          }
        }
      }
    ''';

    final request = json.encode({
      'query': query,
      'variables': {'id': id},
    });

    final result = await post(_url, body: request, headers: _headers);

    final data = json.decode(result.body)['data']['Studio'];

    List<int> years = [data['media']['nodes'][0]['seasonYear']];
    List<List<BrowseResult>> media = [[]];

    for (final m in data['media']['nodes']) {
      if (years.last != m['seasonYear']) {
        years.add(m['seasonYear']);
        media.add([]);
      }

      media.last.add(BrowseResult(
        id: m['id'],
        title: m['title']['userPreferred'],
        imageUrl: m['coverImage']['large'],
        browsable: Browsable.anime,
      ));
    }

    return StudioData(
      name: data['name'],
      media: Tuple(years, media),
      id: id,
      isFavourite: data['isFavourite'],
      favourites: data['favourites'],
      browsable: Browsable.studios,
    );
  }
}
