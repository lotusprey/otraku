import 'package:get/get.dart';
import 'package:otraku/enums/browsable.dart';
import 'package:otraku/helpers/client.dart';
import 'package:otraku/helpers/scroll_x_controller.dart';
import 'package:otraku/models/anilist/media_model.dart';

class Media extends ScrollxController {
  // ***************************************************************************
  // CONSTANTS
  // ***************************************************************************

  static const _mediaQuery = r'''
    query Media($id: Int, $withMain: Boolean = false, $withCharacters: Boolean = false, 
        $withStaff: Boolean = false, $withReviews: Boolean = false, 
        $characterPage: Int = 1, $staffPage: Int = 1, $reviewPage: Int = 1) {
      Media(id: $id) {
        ...main @include(if: $withMain)
        ...reviews @include(if: $withReviews)
        ...characters @include(if: $withCharacters)
        ...staff @include(if: $withStaff)
      }
    }
    fragment main on Media {
      id
      type
      title {userPreferred english romaji native}
      synonyms
      coverImage {extraLarge}
      bannerImage
      isFavourite
      favourites
      mediaListEntry {status}
      nextAiringEpisode {episode timeUntilAiring}
      description
      format
      status(version: 2)
      episodes
      duration
      chapters
      volumes
      season
      seasonYear
      averageScore
      meanScore
      popularity
      startDate {year month day}
      endDate {year month day}
      genres
      studios {edges {isMain node {id name}}}
      source
      hashtag
      countryOfOrigin
      relations {
        edges {
          relationType(version: 2)
          node {
            id
            type
            format
            title {userPreferred} 
            status(version: 2)
            coverImage {large}
          }
        }
      }
    }
    fragment characters on Media {
      characters(page: $characterPage, sort: [ROLE, ID]) {
        pageInfo {hasNextPage}
        edges {
          role
          voiceActors {id name{full} language image{large}}
          node {id name{full} image{large}}
        }
      }
    }
    fragment staff on Media {
      staff(page: $staffPage) {
        pageInfo {hasNextPage}
        edges {role node {id name{full} image{large}}}
      }
    }
    fragment reviews on Media {
      reviews(sort: RATING_DESC, page: $reviewPage) {
        pageInfo {hasNextPage}
        nodes {
          id
          summary
          rating
          ratingAmount
          user {id name avatar{large}}
        }
      }
    }
  ''';

  static const _toggleFavouriteAnimeMutation = r'''
    mutation ToggleFavouriteAnime($id: Int) {
      ToggleFavourite(animeId: $id) {
        anime(page: 1, perPage: 1) {pageInfo {currentPage}}
      }
    }
  ''';

  static const _toggleFavouriteMangaMutation = r'''
    mutation ToggleFavouriteManga($id: Int) {
      ToggleFavourite(mangaId: $id) {
        manga(page: 1, perPage: 1) {pageInfo {currentPage}}
      }
    }
  ''';

  static const OVERVIEW = 0;
  static const RELATIONS = 1;
  static const SOCIAL = 2;
  static const REL_MEDIA = 0;
  static const REL_CHARACTERS = 1;
  static const REL_STAFF = 2;

  // ***************************************************************************
  // DATA
  // ***************************************************************************

  final int _id;
  Media(this._id);

  final _tab = OVERVIEW.obs;
  final _relationsTab = REL_MEDIA.obs;
  final _model = MediaModel();
  final _staffLanguage = 'Japanese'.obs;
  final List<String> _availableLanguages = [];
  bool _fetching = false;

  int get tab => _tab();
  set tab(int value) => _tab.value = value;

  int get relationsTab => _relationsTab();
  set relationsTab(final int val) {
    _relationsTab.value = val;
    if (val == REL_CHARACTERS && _model.characters.items.isEmpty)
      fetchRelationPage(true);
    if (val == REL_STAFF && _model.staff.items.isEmpty)
      fetchRelationPage(false);
  }

  bool get fetching => _fetching;

  MediaModel get model => _model;

  String get staffLanguage => _staffLanguage();
  set staffLanguage(String value) => _staffLanguage.value = value;

  List<String> get availableLanguages => [..._availableLanguages];
  int get languageIndex {
    final index = _availableLanguages.indexOf(_staffLanguage());
    if (index != -1) return index;
    return 0;
  }

  // ***************************************************************************
  // FETCHING
  // ***************************************************************************

  Future<void> fetch() async {
    if (_model.overview != null) return;
    _fetching = true;

    final result = await Client.request(_mediaQuery, {
      'id': _id,
      'withMain': true,
      'withReviews': true,
    });

    if (result == null) return;
    _model.setMain(result['Media']);
    _model.addReviews(result['Media']);
    _fetching = false;
  }

  Future<void> fetchRelationPage(bool ofCharacters) async {
    if (ofCharacters && !_model.characters.hasNextPage) return;
    if (!ofCharacters && !_model.staff.hasNextPage) return;
    _fetching = true;

    final result = await Client.request(_mediaQuery, {
      'id': _id,
      'withCharacters': ofCharacters,
      'withStaff': !ofCharacters,
      'characterPage': _model.characters.nextPage,
      'staffPage': _model.staff.nextPage,
    });

    if (result == null) return;
    if (ofCharacters)
      _model.addCharacters(result['Media'], _availableLanguages);
    else
      _model.addStaff(result['Media']);
    _fetching = false;
  }

  Future<void> fetchReviewPage() async {
    if (!_model.reviews.hasNextPage) return;
    _fetching = true;

    final result = await Client.request(_mediaQuery, {
      'id': _id,
      'withReviews': true,
      'reviewPage': _model.reviews.nextPage,
    });

    if (result == null) return;
    _model.addReviews(result['Media']);
    _fetching = false;
  }

  Future<bool> toggleFavourite() async =>
      await Client.request(
        _model.overview.browsable == Browsable.anime
            ? _toggleFavouriteAnimeMutation
            : _toggleFavouriteMangaMutation,
        {'id': _id},
        popOnErr: false,
      ) !=
      null;

  @override
  void onInit() {
    super.onInit();
    fetch();
  }
}
