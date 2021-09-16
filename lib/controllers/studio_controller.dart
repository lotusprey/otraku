import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:otraku/models/studio_model.dart';
import 'package:otraku/utils/client.dart';
import 'package:otraku/utils/convert.dart';
import 'package:otraku/enums/media_sort.dart';
import 'package:otraku/models/group_page_model.dart';
import 'package:otraku/models/explorable_model.dart';
import 'package:otraku/utils/overscroll_controller.dart';

class StudioController extends OverscrollController {
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
      isAnimationStudio
    }
  ''';

  static const _toggleFavouriteMutation = r'''
    mutation ToggleFavouriteStudio($id: Int) {
      ToggleFavourite(studioId: $id) {
        studios(page: 1, perPage: 1) {nodes{isFavourite}}
      }
    }
  ''';

  // ***************************************************************************
  // DATA
  // ***************************************************************************

  final int id;
  StudioController(this.id);

  StudioModel? _model;
  final _media = GroupPageModel<ExplorableModel>().obs;
  MediaSort _sort = MediaSort.START_DATE_DESC;
  bool? _onList;

  StudioModel? get model => _model;
  GroupPageModel<ExplorableModel> get media => _media();

  @override
  bool get hasNextPage => _media().hasNextPage;

  MediaSort get sort => _sort;
  set sort(MediaSort value) {
    _sort = value;
    refetch();
  }

  bool? get onList => _onList;
  set onList(bool? val) {
    _onList = val;
    refetch();
  }

  // ***************************************************************************
  // FETCHING
  // ***************************************************************************

  Future<void> fetch() async {
    final data = await Client.request(
      _studioQuery,
      {
        'id': id,
        'withStudio': true,
        'sort': describeEnum(_sort),
        'onList': _onList,
      },
    );
    if (data == null) return;

    _model = StudioModel(data['Studio']);
    update();

    _initMedia(data['Studio']['media'], false);
  }

  Future<void> refetch() async {
    final data = await Client.request(
      _studioQuery,
      {'id': id, 'sort': describeEnum(_sort), 'onList': _onList},
    );
    if (data == null) return;

    _initMedia(data['Studio']['media'], true);
  }

  @override
  Future<void> fetchPage() async {
    final data = await Client.request(
      _studioQuery,
      {
        'id': id,
        'page': _media().nextPage,
        'sort': describeEnum(_sort),
        'onList': _onList,
      },
    );
    if (data == null) return;

    _initMedia(data['Studio']['media'], false);
  }

  Future<bool> toggleFavourite() async {
    final data = await Client.request(_toggleFavouriteMutation, {'id': id});
    if (data != null) _model!.isFavourite = !_model!.isFavourite;
    return _model!.isFavourite;
  }

  // ***************************************************************************
  // HELPER FUNCTIONS
  // ***************************************************************************

  void _initMedia(Map<String, dynamic> data, bool clear) {
    if (clear) _media().clear();

    final categories = <String>[];
    final results = <List<ExplorableModel>>[];

    for (final node in data['nodes']) {
      final String category =
          (node['startDate']['year'] ?? Convert.clarifyEnum(node['status']))
              .toString();

      if (categories.isEmpty || categories.last != category) {
        categories.add(category);
        results.add([]);
      }

      results.last.add(ExplorableModel.anime(node));
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
