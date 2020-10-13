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
  static const String _personMain = r'''
    name{full native alternative}
    image{large}
    favourites 
    isFavourite
    description(asHtml: true)
  ''';

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

  Future<PersonData> fetchCharacter(int id, PersonData character) async {
    final query = '''
      query Character(\$id: Int, \$page: Int) {
        Character(id: \$id) {
          ${character == null ? _personMain : ''}
          anime: media(page: \$page, type: ANIME) {
            ...media
          }
          manga: media(page: \$page, type: MANGA) {
            ...media
          }
        }
      }
      fragment media on MediaConnection {
        edges {
          characterRole
          voiceActors {
            id
            name {
              full
            }
            image {
              large
            }
            language
          }
          node {
            id
            title {
              userPreferred
            }
            coverImage {
              large
            }
          }
        }
      }
    ''';

    final request = json.encode({
      'query': query,
      'variables': {
        'id': id,
        'page': character == null ? 1 : character.nextPage,
      },
    });

    final result = await post(_url, body: request, headers: _headers);

    final data = json.decode(result.body)['data']['Character'];

    if (character == null) {
      character = PersonData(
        id: id,
        fullName: data['name']['full'],
        altNames: (data['name']['alternative'] as List<dynamic>)
            .map((a) => a.toString())
            .toList()
              ..insert(0, data['name']['native']),
        imageUrl: data['image']['large'],
        description:
            data['description'].toString().replaceAll(RegExp(r'<[^>]*>'), ''),
        isFavourite: data['isFavourite'],
        favourites: data['favourites'],
        browsable: Browsable.characters,
        primaryConnections: [],
        secondaryConnections: [],
      );
    }

    List<Connection> primaryConnections = [];
    List<Connection> secondaryConnections = [];

    for (final connection in data['anime']['edges']) {
      List<Connection> voiceActors = [];
      for (final va in connection['voiceActors']) {
        voiceActors.add(Connection(
          id: va['id'],
          title: va['name']['full'],
          imageUrl: va['image']['large'],
          text: clarifyEnum(va['language']),
          browsable: Browsable.staff,
        ));
      }

      primaryConnections.add(Connection(
        others: voiceActors,
        id: connection['node']['id'],
        title: connection['node']['title']['userPreferred'],
        text: clarifyEnum(connection['characterRole']),
        imageUrl: connection['node']['coverImage']['large'],
        browsable: Browsable.anime,
      ));
    }

    for (final connection in data['manga']['edges']) {
      secondaryConnections.add(Connection(
        id: connection['node']['id'],
        title: connection['node']['title']['userPreferred'],
        text: clarifyEnum(connection['characterRole']),
        imageUrl: connection['node']['coverImage']['large'],
        browsable: Browsable.manga,
      ));
    }

    return character
      ..appendConnections(primaryConnections, secondaryConnections);
  }

  Future<PersonData> fetchStaff(int id, PersonData staff) async {
    final query = '''
      query Staff(\$id: Int, \$page: Int) {
        Staff(id: \$id) {
          ${staff == null ? _personMain : ''}
          characters(page: \$page) {
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
          staffMedia(page: \$page) {
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
      'variables': {'id': id, 'page': staff == null ? 1 : staff.nextPage},
    });

    final result = await post(_url, body: request, headers: _headers);

    final data = json.decode(result.body)['data']['Staff'];

    if (staff == null) {
      List<String> altNames = (data['name']['alternative'] as List<dynamic>)
          .map((a) => a.toString())
          .toList();
      if (data['name']['native'] != null)
        altNames.insert(0, data['name']['native']);

      staff = PersonData(
        id: id,
        fullName: data['name']['full'],
        altNames: altNames,
        imageUrl: data['image']['large'],
        description:
            data['description'].toString().replaceAll(RegExp(r'<[^>]*>'), ''),
        isFavourite: data['isFavourite'],
        favourites: data['favourites'],
        browsable: Browsable.staff,
        primaryConnections: [],
        secondaryConnections: [],
      );
    }

    List<Connection> primaryConnections = [];
    List<Connection> secondaryConnections = [];

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

    return staff..appendConnections(primaryConnections, secondaryConnections);
  }

  Future<StudioData> fetchStudio(int id, StudioData studio) async {
    final query = '''
      query Studio(\$id: Int, \$page: Int) {
        Studio(id: \$id) {
          ${studio == null ? """
            name
            favourites 
            isFavourite
          """ : ''}
          media(sort: START_DATE_DESC, page: \$page) {
            nodes {
              id
              title {userPreferred}
              coverImage {large}
              startDate {year}
              status
            }
          }
        }
      }
    ''';

    final request = json.encode({
      'query': query,
      'variables': {'id': id, 'page': studio == null ? 1 : studio.nextPage},
    });

    final result = await post(_url, body: request, headers: _headers);

    final data = json.decode(result.body)['data']['Studio'];

    String firstYearElement = (data['media']['nodes'][0]['startDate']['year'] ??
            clarifyEnum(data['media']['nodes'][0]['status']))
        .toString();

    if (studio == null) {
      studio = StudioData(
        id: id,
        name: data['name'],
        isFavourite: data['isFavourite'],
        favourites: data['favourites'],
        browsable: Browsable.studios,
        media: Tuple([firstYearElement], [[]]),
      );
    }

    List<String> years = [firstYearElement];
    List<List<BrowseResult>> media = [[]];

    for (final m in data['media']['nodes']) {
      String year =
          (m['startDate']['year'] ?? clarifyEnum(m['status'])).toString();
      if (years.last != year) {
        years.add(year);
        media.add([]);
      }

      media.last.add(BrowseResult(
        id: m['id'],
        title: m['title']['userPreferred'],
        imageUrl: m['coverImage']['large'],
        browsable: Browsable.anime,
      ));
    }

    return studio..appendMedia(years, media);
  }
}
