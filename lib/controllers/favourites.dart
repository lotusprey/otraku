import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:otraku/controllers/user.dart';
import 'package:otraku/models/helper_models/browse_result_model.dart';
import 'package:otraku/models/user_model.dart';
import 'package:otraku/utils/client.dart';
import 'package:otraku/utils/scroll_x_controller.dart';

class Favourites extends ScrollxController {
  static const _favouritesQuery = r'''
    query Favourites($id: Int, $page: Int, $withAnime: Boolean = false, $withManga: Boolean = false, 
        $withCharacters: Boolean = false, $withStaff: Boolean = false, $withStudios: Boolean = false) {
      User(id: $id) {
        favourites {
          anime(page: $page) @include(if: $withAnime) {...media}
          manga(page: $page) @include(if: $withManga) {...media}
          characters(page: $page) @include(if: $withCharacters) {...character}
          staff(page: $page) @include(if: $withStaff) {...staff}
          studios(page: $page) @include(if: $withStudios) {...studio}
        }
      }
    }
    fragment media on MediaConnection {
      pageInfo {hasNextPage} nodes {id title {userPreferred} coverImage {large}}
    }
    fragment character on CharacterConnection {
      pageInfo {hasNextPage} nodes {id name {full} image {large}}
    }
    fragment staff on StaffConnection {
      pageInfo {hasNextPage} nodes {id name {full} image {large}}
    }
    fragment studio on StudioConnection {pageInfo {hasNextPage} nodes {id name}}
  ''';

  final int id;
  Favourites(this.id);

  late UserModel _model;
  int _pageIndex = UserModel.ANIME_FAV;
  final _keys = [
    UniqueKey(),
    UniqueKey(),
    UniqueKey(),
    UniqueKey(),
    UniqueKey(),
  ];

  @override
  bool get hasNextPage => _model.favourites[_pageIndex].hasNextPage;
  List<BrowseResultModel> get favourites => _model.favourites[_pageIndex].items;
  UniqueKey get key => _keys[_pageIndex];

  int get pageIndex => _pageIndex;
  set pageIndex(int index) {
    _pageIndex = index;
    scrollTo(0).then((_) => update());
  }

  String get pageName {
    if (_pageIndex == UserModel.ANIME_FAV) return 'Anime';
    if (_pageIndex == UserModel.MANGA_FAV) return 'Manga';
    if (_pageIndex == UserModel.CHARACTER_FAV) return 'Characters';
    if (_pageIndex == UserModel.STAFF_FAV) return 'Staff';
    return 'Studios';
  }

  @override
  Future<void> fetchPage() async {
    final data = await Client.request(_favouritesQuery, {
      'id': id,
      'withAnime': _pageIndex == UserModel.ANIME_FAV,
      'withManga': _pageIndex == UserModel.MANGA_FAV,
      'withCharacters': _pageIndex == UserModel.CHARACTER_FAV,
      'withStaff': _pageIndex == UserModel.STAFF_FAV,
      'withStudios': _pageIndex == UserModel.STUDIO_FAV,
      'page': _model.favourites[_pageIndex].nextPage,
    });
    if (data == null) return;

    _model.addFavs(_pageIndex, data['User']['favourites']);
    update();
  }

  @override
  void onInit() {
    super.onInit();
    _model = Get.find<User>(tag: id.toString()).model!;
  }
}
