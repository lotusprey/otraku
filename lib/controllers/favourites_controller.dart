import 'package:get/get.dart';
import 'package:otraku/controllers/user_controller.dart';
import 'package:otraku/models/explorable_model.dart';
import 'package:otraku/models/user_model.dart';
import 'package:otraku/utils/client.dart';
import 'package:otraku/utils/overscroll_controller.dart';

class FavouritesController extends OverscrollController {
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
      pageInfo {hasNextPage} nodes {id name {userPreferred} image {large}}
    }
    fragment staff on StaffConnection {
      pageInfo {hasNextPage} nodes {id name {userPreferred} image {large}}
    }
    fragment studio on StudioConnection {pageInfo {hasNextPage} nodes {id name}}
  ''';

  final int id;
  FavouritesController(this.id);

  late UserModel _model;
  int _pageIndex = UserModel.ANIME_FAV;

  @override
  bool get hasNextPage => _model.favourites[_pageIndex].hasNextPage;
  List<ExplorableModel> get favourites => _model.favourites[_pageIndex].items;

  int get pageIndex => _pageIndex;
  set pageIndex(int index) {
    if (index < 0 || index > 4) return;
    _pageIndex = index;
    scrollTo(0).then((_) => update());
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
    _model = Get.find<UserController>(tag: id.toString()).model!;
  }
}
