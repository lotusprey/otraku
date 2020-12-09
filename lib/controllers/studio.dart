import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:otraku/controllers/network_service.dart';
import 'package:otraku/enums/browsable_enum.dart';
import 'package:otraku/enums/enum_helper.dart';
import 'package:otraku/enums/media_sort_enum.dart';
import 'package:otraku/models/page_data/page_object.dart';
import 'package:otraku/models/page_data/studio_connection_list.dart';
import 'package:otraku/models/sample_data/browse_result.dart';

class Studio extends GetxController {
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

  final _company = Rx<PageObject>();
  final _media = Rx<StudioConnectionList>();
  MediaSort _sort = MediaSort.START_DATE_DESC;

  PageObject get company => _company();

  StudioConnectionList get media => _media();

  MediaSort get sort => _sort;

  set sort(MediaSort value) {
    _sort = value;
    refetch();
  }

  Future<void> fetchStudio(int id) async {
    if (_company.value != null) return;

    final body = await NetworkService.request(
      _studioQuery,
      {'id': id, 'withStudio': true, 'sort': describeEnum(_sort)},
    );

    if (body == null) return;

    final data = body['Studio'];

    _company(PageObject(
      id: id,
      browsable: Browsable.studio,
      isFavourite: data['isFavourite'],
      favourites: data['favourites'],
    ));

    _initLists(data['media']);
  }

  Future<void> refetch() async {
    final body = await NetworkService.request(
      _studioQuery,
      {'id': _company().id, 'sort': describeEnum(_sort)},
    );

    if (body == null) return;

    _initLists(body['Studio']['media']);
  }

  Future<void> fetchPage() async {
    final body = await NetworkService.request(
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
    List<List<BrowseResult>> results = [];
    for (final node in data['nodes']) {
      final String category =
          (node['startDate']['year'] ?? clarifyEnum(node['status'])).toString();

      if (categories.isEmpty || categories.last != category) {
        categories.add(category);
        results.add([]);
      }

      results.last.add(BrowseResult(
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

  void _initLists(Map<String, dynamic> data) {
    final List<dynamic> nodes = data['nodes'];
    if (nodes.isEmpty) {
      _media(StudioConnectionList([], [], false));
      return;
    }

    List<String> categories = [];
    List<List<BrowseResult>> results = [];
    for (final node in nodes) {
      final String category =
          (node['startDate']['year'] ?? clarifyEnum(node['status'])).toString();

      if (categories.isEmpty || categories.last != category) {
        categories.add(category);
        results.add([]);
      }

      results.last.add(BrowseResult(
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
