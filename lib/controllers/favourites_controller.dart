import 'package:get/get.dart';
import 'package:otraku/controllers/user_controller.dart';
import 'package:otraku/models/explorable_model.dart';
import 'package:otraku/models/user_model.dart';
import 'package:otraku/utils/client.dart';
import 'package:otraku/utils/graphql.dart';
import 'package:otraku/utils/scrolling_controller.dart';

class FavouritesController extends ScrollingController {
  FavouritesController(this.id);

  final int id;
  late UserModel _model;
  int _pageIndex = UserModel.ANIME_FAV;

  List<ExplorableModel> get favourites => _model.favourites[_pageIndex].items;

  int get pageIndex => _pageIndex;
  set pageIndex(int index) {
    if (index < 0 || index > 4) return;
    _pageIndex = index;
    scrollUpTo(0).then((_) => update());
  }

  @override
  Future<void> fetchPage() async {
    if (!_model.favourites[_pageIndex].hasNextPage) return;

    final data = await Client.request(GqlQuery.user, {
      'id': id,
      'page': _model.favourites[_pageIndex].nextPage,
      'withAnime': _pageIndex == UserModel.ANIME_FAV,
      'withManga': _pageIndex == UserModel.MANGA_FAV,
      'withCharacters': _pageIndex == UserModel.CHARACTER_FAV,
      'withStaff': _pageIndex == UserModel.STAFF_FAV,
      'withStudios': _pageIndex == UserModel.STUDIO_FAV,
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
