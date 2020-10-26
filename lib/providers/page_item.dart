import 'package:otraku/enums/browsable_enum.dart';
import 'package:otraku/enums/enum_helper.dart';
import 'package:otraku/models/page_data/person_data.dart';
import 'package:otraku/models/page_data/studio_data.dart';
import 'package:otraku/models/sample_data/browse_result.dart';
import 'package:otraku/models/sample_data/connection.dart';
import 'package:otraku/models/tuple.dart';
import 'package:otraku/providers/network_service.dart';

class PageItem {
  static const String _personMain = r'''
    name{full native alternative}
    image{large}
    favourites 
    isFavourite
    description(asHtml: true)
  ''';

  static Future<bool> toggleFavourite(int id, Browsable browsable) async {
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

    final result = await NetworkService.request(
      query,
      {'id': id},
      popOnError: false,
    );

    return result != null;
  }

  static Future<PersonData> fetchCharacter(int id, PersonData character) async {
    const anime = r'''
      anime: media(page: $page, type: ANIME) {
        ...media
      }
    ''';

    const manga = r'''
      manga: media(page: $page, type: MANGA) {
        ...media
      }
    ''';

    final query = '''
      query Character(\$id: Int, \$page: Int) {
        Character(id: \$id) {
          ${character == null ? _personMain + anime + manga : character.currentlyOnLeftPage ? anime : manga}
        }
      }
      fragment media on MediaConnection {
        pageInfo {hasNextPage}
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

    final body = await NetworkService.request(query, {
      'id': id,
      'page': character == null ? 1 : character.nextPage,
    });

    if (body == null) return null;

    final data = body['Character'];

    List<Connection> leftConnections = [];
    List<Connection> rightConnections = [];

    if (character == null || character.currentlyOnLeftPage)
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

        leftConnections.add(Connection(
          others: voiceActors,
          id: connection['node']['id'],
          title: connection['node']['title']['userPreferred'],
          text: clarifyEnum(connection['characterRole']),
          imageUrl: connection['node']['coverImage']['large'],
          browsable: Browsable.anime,
        ));
      }

    if (character == null || !character.currentlyOnLeftPage)
      for (final connection in data['manga']['edges']) {
        rightConnections.add(Connection(
          id: connection['node']['id'],
          title: connection['node']['title']['userPreferred'],
          text: clarifyEnum(connection['characterRole']),
          imageUrl: connection['node']['coverImage']['large'],
          browsable: Browsable.manga,
        ));
      }

    if (character == null) {
      List<String> altNames = (data['name']['alternative'] as List<dynamic>)
          .map((a) => a.toString())
          .toList();
      if (data['name']['native'] != null)
        altNames.insert(0, data['name']['native']);

      character = PersonData(
        id: id,
        fullName: data['name']['full'],
        altNames: altNames,
        imageUrl: data['image']['large'],
        description:
            data['description'].toString().replaceAll(RegExp(r'<[^>]*>'), ''),
        isFavourite: data['isFavourite'],
        favourites: data['favourites'],
        browsable: Browsable.characters,
        leftConnections: [],
        rightConnections: [],
      );
    }

    if (data['anime'] != null)
      character.appendLeft(
          leftConnections, data['anime']['pageInfo']['hasNextPage']);
    if (data['manga'] != null)
      character.appendRight(
          rightConnections, data['manga']['pageInfo']['hasNextPage']);

    if (character.leftConnections.length == 0 &&
        character.rightConnections.length > 0) {
      character.currentlyOnLeftPage = false;
    }

    return character;
  }

  static Future<PersonData> fetchStaff(int id, PersonData staff) async {
    const characters = r'''
      characters(page: $page) {
        pageInfo {hasNextPage}
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
    ''';

    const staffMedia = r'''
      staffMedia(page: $page) {
        pageInfo {hasNextPage}
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
    ''';

    final query = '''
      query Staff(\$id: Int, \$page: Int) {
        Staff(id: \$id) {
          ${staff == null ? _personMain + characters + staffMedia : staff.currentlyOnLeftPage ? characters : staffMedia}
        }
      }
    ''';

    final body = await NetworkService.request(query, {
      'id': id,
      'page': staff == null ? 1 : staff.nextPage,
    });

    if (body == null) return null;

    final data = body['Staff'];

    List<Connection> leftConnections = [];
    List<Connection> rightConnections = [];

    if (staff == null || staff.currentlyOnLeftPage)
      for (final connection in data['characters']['edges']) {
        if (connection['media'].length > 0)
          leftConnections.add(Connection(
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

    if (staff == null || !staff.currentlyOnLeftPage)
      for (final connection in data['staffMedia']['edges']) {
        rightConnections.add(Connection(
          id: connection['node']['id'],
          title: connection['node']['title']['userPreferred'],
          text: connection['staffRole'],
          imageUrl: connection['node']['coverImage']['large'],
          browsable: connection['node']['type'] == 'ANIME'
              ? Browsable.anime
              : Browsable.manga,
        ));
      }

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
        leftConnections: [],
        rightConnections: [],
      );
    }

    if (data['characters'] != null)
      staff.appendLeft(
          leftConnections, data['characters']['pageInfo']['hasNextPage']);
    if (data['staffMedia'] != null)
      staff.appendRight(
          rightConnections, data['staffMedia']['pageInfo']['hasNextPage']);

    if (staff.leftConnections.length == 0 &&
        staff.rightConnections.length > 0) {
      staff.currentlyOnLeftPage = false;
    }

    return staff;
  }

  static Future<StudioData> fetchStudio(int id, StudioData studio) async {
    final query = '''
      query Studio(\$id: Int, \$page: Int) {
        Studio(id: \$id) {
          ${studio == null ? """
            name
            favourites 
            isFavourite
          """ : ''}
          media(sort: START_DATE_DESC, page: \$page) {
            pageInfo {hasNextPage}
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

    final body = await NetworkService.request(query, {
      'id': id,
      'page': studio == null ? 1 : studio.nextPage,
    });

    if (body == null) return null;

    final data = body['Studio'];

    if ((data['media']['nodes'] as List<dynamic>).length == 0) return studio;

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

    return studio
      ..appendMedia(years, media, data['media']['pageInfo']['hasNextPage']);
  }
}
