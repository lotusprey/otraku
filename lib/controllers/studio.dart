import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:otraku/helpers/network.dart';
import 'package:otraku/enums/browsable.dart';
import 'package:otraku/helpers/fn_helper.dart';
import 'package:otraku/enums/media_sort.dart';
import 'package:otraku/models/anilist/studio_data.dart';
import 'package:otraku/models/studio_connection_list.dart';
import 'package:otraku/models/tile_data.dart';

class Studio extends GetxController {
  // ***************************************************************************
  // CONSTANTS
  // ***************************************************************************

  static const _studioQuery = r'''
    query Studio($id: Int, $page: Int = 1, $sort: [MediaSort], $isMain: Boolean, $onList: Boolean, $withStudio: Boolean = false) {
      Studio(id: $id) {
        ...studio @include(if: $withStudio)
        media(page: $page, sort: $sort, isMain: $isMain, onList: $onList) {
          pageInfo {hasNextPage}
          nodes {
            id
            title {userPreferred}
            coverImage {large}
            startDate {year}
            status(version: 2)
          }
        }
      }
    }
    fragment studio on Studio {
      name
      favourites
      isFavourite
    }
  ''';

  static const _toggleFavouriteMutation = r'''
    mutation ToggleFavouriteStudio($id: Int) {
      ToggleFavourite(studioId: $id) {
        studios(page: 1, perPage: 1) {pageInfo {currentPage}}
      }
    }
  ''';

  // ***************************************************************************
  // DATA
  // ***************************************************************************

  final _company = Rx<StudioData>();
  final _media = Rx<StudioConnectionList>();
  MediaSort _sort = MediaSort.START_DATE_DESC;

  StudioData get company => _company();

  StudioConnectionList get media => _media();

  MediaSort get sort => _sort;

  set sort(MediaSort value) {
    _sort = value;
    refetch();
  }

  // ***************************************************************************
  // FETCHING
  // ***************************************************************************

  Future<void> fetchStudio(int id) async {
    if (_company.value != null) return;

    final body = await Network.request(
      _studioQuery,
      {'id': id, 'withStudio': true, 'sort': describeEnum(_sort)},
    );
    if (body == null) return;

    final data = body['Studio'];

    _company(StudioData.studio(data, id));

    _initLists(data['media']);
  }

  Future<void> refetch() async {
    final body = await Network.request(
      _studioQuery,
      {'id': _company().id, 'sort': describeEnum(_sort)},
    );

    if (body == null) return;

    _initLists(body['Studio']['media']);
  }

  Future<void> fetchPage() async {
    final body = await Network.request(
      _studioQuery,
      {
        'id': _company().id,
        'page': _media().nextPage,
        'sort': describeEnum(_sort),
      },
    );

    if (body == null) return;

    final data = body['Studio']['media'];

    List<String> categories = [];
    List<List<TileData>> results = [];
    for (final node in data['nodes']) {
      final String category =
          (node['startDate']['year'] ?? FnHelper.clarifyEnum(node['status']))
              .toString();

      if (categories.isEmpty || categories.last != category) {
        categories.add(category);
        results.add([]);
      }

      results.last.add(TileData(
        id: node['id'],
        title: node['title']['userPreferred'],
        imageUrl: node['coverImage']['large'],
        browsable: Browsable.anime,
      ));
    }

    _media.update((m) => m.append(
          categories,
          results,
          data['pageInfo']['hasNextPage'],
        ));
  }

  Future<bool> toggleFavourite() async =>
      await Network.request(
        _toggleFavouriteMutation,
        {'id': _company().id},
        popOnErr: false,
      ) !=
      null;

  // ***************************************************************************
  // HELPER FUNCTIONS
  // ***************************************************************************

  void _initLists(Map<String, dynamic> data) {
    final List<dynamic> nodes = data['nodes'];
    if (nodes.isEmpty) {
      _media(StudioConnectionList([], [], false));
      return;
    }

    List<String> categories = [];
    List<List<TileData>> results = [];
    for (final node in nodes) {
      final String category =
          (node['startDate']['year'] ?? FnHelper.clarifyEnum(node['status']))
              .toString();

      if (categories.isEmpty || categories.last != category) {
        categories.add(category);
        results.add([]);
      }

      results.last.add(TileData(
        id: node['id'],
        title: node['title']['userPreferred'],
        imageUrl: node['coverImage']['large'],
        browsable: Browsable.anime,
      ));
    }

    _media(StudioConnectionList(
      categories,
      results,
      data['pageInfo']['hasNextPage'],
    ));
  }
}
