import 'package:get/get.dart';
import 'package:otraku/enums/browsable.dart';
import 'package:otraku/models/loadable_list.dart';
import 'package:otraku/models/browse_result_model.dart';
import 'package:otraku/helpers/graph_ql.dart';
import 'package:otraku/models/anilist/user_model.dart';

class User extends GetxController {
  static const _userQuery = r'''
      query User($id: Int, $withMain: Boolean = false, $withAnime: Boolean = false, $withManga: Boolean = false, 
          $withCharacters: Boolean = false, $withStaff: Boolean = false, $withStudios: Boolean = false,
          $favsPage: Int = 1) {
        User(id: $id) {
          ...main @include(if: $withMain)
          favourites {
            anime(page: $favsPage) @include(if: $withAnime) {...media}
            manga(page: $favsPage) @include(if: $withManga) {...media}
            characters(page: $favsPage) @include(if: $withCharacters) {...character}
            staff(page: $favsPage) @include(if: $withStaff) {...staff}
            studios(page: $favsPage) @include(if: $withStudios) {...studio}
          }
        }
      }
      fragment main on User {
        id
        name
        about(asHtml: true)
        avatar {large}
        bannerImage
        isFollowing
        isFollower
        isBlocked
        donatorBadge
        moderatorStatus
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

  static const _toggleFollow =
      r'''mutation FollowUser($id: Int) {ToggleFollow(userId: $id) {isFollowing}}''';

  static const ANIME_FAV = 0;
  static const MANGA_FAV = 1;
  static const CHARACTER_FAV = 2;
  static const STAFF_FAV = 3;
  static const STUDIO_FAV = 4;

  UserModel _user;
  int _favsIndex = ANIME_FAV;
  bool _loading = true;
  final _favourites = [
    LoadableList<BrowseResultModel>([], true),
    LoadableList<BrowseResultModel>([], true),
    LoadableList<BrowseResultModel>([], true),
    LoadableList<BrowseResultModel>([], true),
    LoadableList<BrowseResultModel>([], true),
  ];

  UserModel get person => _user;

  List<BrowseResultModel> get favourites => _favourites[_favsIndex].items;

  int get favsIndex => _favsIndex;

  set favsIndex(int index) {
    _favsIndex = index;
    update();
  }

  bool get loading => _loading;

  String get favPageName {
    if (_favsIndex == ANIME_FAV) return 'Anime';
    if (_favsIndex == MANGA_FAV) return 'Manga';
    if (_favsIndex == CHARACTER_FAV) return 'Characters';
    if (_favsIndex == STAFF_FAV) return 'Staff';
    return 'Studios';
  }

  // ***************************************************************************
  // FETCHING
  // ***************************************************************************

  Future<void> fetchUser(int id) async {
    final data = await GraphQL.request(
      _userQuery,
      {
        'id': id ?? GraphQL.viewerId,
        'withMain': true,
        'withAnime': true,
        'withManga': true,
        'withCharacters': true,
        'withStaff': true,
        'withStudios': true,
      },
      popOnErr: id != null,
    );

    if (data == null) return;

    _user = UserModel(data['User'], id == null);
    final favs = data['User']['favourites'];

    _appendMediaFavs(favs['anime'], ANIME_FAV, Browsable.anime);
    _appendMediaFavs(favs['manga'], MANGA_FAV, Browsable.manga);
    _appendPersonFavs(favs['characters'], CHARACTER_FAV, Browsable.character);
    _appendPersonFavs(favs['staff'], STAFF_FAV, Browsable.staff);
    _appendStudioFavs(favs['studios']);

    _loading = false;
    update();
  }

  Future<void> fetchFavourites() async {
    if (_loading || !_favourites[_favsIndex].hasNextPage) return;
    _loading = true;

    final data = await GraphQL.request(_userQuery, {
      'id': _user.id,
      'withAnime': _favsIndex == ANIME_FAV,
      'withManga': _favsIndex == MANGA_FAV,
      'withCharacters': _favsIndex == CHARACTER_FAV,
      'withStaff': _favsIndex == STAFF_FAV,
      'withStudios': _favsIndex == STUDIO_FAV,
      'favsPage': _favourites[_favsIndex].nextPage,
    });

    if (data == null) return;

    final favs = data['User']['favourites'];
    switch (_favsIndex) {
      case ANIME_FAV:
        _appendMediaFavs(favs['anime'], ANIME_FAV, Browsable.anime);
        break;
      case MANGA_FAV:
        _appendMediaFavs(favs['manga'], MANGA_FAV, Browsable.manga);
        break;
      case CHARACTER_FAV:
        _appendPersonFavs(
            favs['characters'], CHARACTER_FAV, Browsable.character);
        break;
      case STAFF_FAV:
        _appendPersonFavs(favs['staff'], STAFF_FAV, Browsable.staff);
        break;
      default:
        _appendStudioFavs(favs['studios']);
        break;
    }

    _loading = false;
    update();
  }

  Future<void> toggleFollow() async {
    final data = await GraphQL.request(_toggleFollow, {'id': _user.id});
    if (data == null) return;
    _user.toggleFollow(data['ToggleFollow']);
    update();
  }

  // ***************************************************************************
  // HELPER FUNCTIONS
  // ***************************************************************************

  void _appendMediaFavs(
    Map<String, dynamic> data,
    int page,
    Browsable browsable,
  ) {
    final List<BrowseResultModel> items = [];
    for (final node in data['nodes'])
      items.add(BrowseResultModel(
        id: node['id'],
        title: node['title']['userPreferred'],
        imageUrl: node['coverImage']['large'],
        browsable: browsable,
      ));
    _favourites[page].append(items, data['pageInfo']['hasNextPage']);
  }

  void _appendPersonFavs(
    Map<String, dynamic> data,
    int page,
    Browsable browsable,
  ) {
    final List<BrowseResultModel> items = [];
    for (final node in data['nodes'])
      items.add(BrowseResultModel(
        id: node['id'],
        title: node['name']['full'],
        imageUrl: node['image']['large'],
        browsable: browsable,
      ));
    _favourites[page].append(items, data['pageInfo']['hasNextPage']);
  }

  void _appendStudioFavs(Map<String, dynamic> data) {
    final List<BrowseResultModel> items = [];
    for (final node in data['nodes'])
      items.add(BrowseResultModel(
        id: node['id'],
        title: node['name'],
        browsable: Browsable.studio,
      ));
    _favourites[STUDIO_FAV].append(items, data['pageInfo']['hasNextPage']);
  }
}
