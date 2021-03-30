import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:otraku/utils/client.dart';
import 'package:otraku/utils/convert.dart';
import 'package:otraku/enums/media_sort.dart';
import 'package:otraku/models/person_model.dart';
import 'package:otraku/models/studio_page_model.dart';
import 'package:otraku/models/helper_models/browse_result_model.dart';

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
      id
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

  final int _id;
  Studio(this._id);

  final _company = Rx<PersonModel?>(null);
  final _media = StudioPageModel().obs;
  MediaSort _sort = MediaSort.START_DATE_DESC;

  PersonModel? get company => _company();

  StudioPageModel get media => _media();

  MediaSort get sort => _sort;

  set sort(MediaSort value) {
    _sort = value;
    refetch();
  }

  // ***************************************************************************
  // FETCHING
  // ***************************************************************************

  Future<void> fetch() async {
    if (_company.value != null) return;

    final data = await Client.request(
      _studioQuery,
      {'id': _id, 'withStudio': true, 'sort': describeEnum(_sort)},
    );
    if (data == null) return;

    _company(PersonModel.studio(data['Studio']));
    _initMedia(data['Studio']['media'], false);
  }

  Future<void> refetch() async {
    final data = await Client.request(
      _studioQuery,
      {'id': _id, 'sort': describeEnum(_sort)},
    );
    if (data == null) return;

    _initMedia(data['Studio']['media'], true);
  }

  Future<void> fetchPage() async {
    if (!_media().hasNextPage) return;

    final data = await Client.request(
      _studioQuery,
      {
        'id': _id,
        'page': _media().nextPage,
        'sort': describeEnum(_sort),
      },
    );
    if (data == null) return;

    _initMedia(data['Studio']['media'], false);
  }

  Future<bool> toggleFavourite() async =>
      await Client.request(
        _toggleFavouriteMutation,
        {'id': _id},
        popOnErr: false,
      ) !=
      null;

  // ***************************************************************************
  // HELPER FUNCTIONS
  // ***************************************************************************

  void _initMedia(Map<String, dynamic> data, bool clear) {
    if (clear) _media().clear();

    final categories = <String>[];
    final results = <List<BrowseResultModel>>[];

    for (final node in data['nodes']) {
      final String category =
          (node['startDate']['year'] ?? Convert.clarifyEnum(node['status']))
              .toString();

      if (categories.isEmpty || categories.last != category) {
        categories.add(category);
        results.add([]);
      }

      results.last.add(BrowseResultModel.anime(node));
    }

    _media.update((m) => m!.append(
          categories,
          results,
          data['pageInfo']['hasNextPage'],
        ));
  }

  @override
  void onInit() {
    super.onInit();
    fetch();
  }
}
