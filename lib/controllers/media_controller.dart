import 'package:get/get.dart';
import 'package:otraku/enums/explorable.dart';
import 'package:otraku/utils/client.dart';
import 'package:otraku/utils/overscroll_controller.dart';
import 'package:otraku/models/media_model.dart';

class MediaController extends OverscrollController {
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
      nextAiringEpisode {episode airingAt}
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
      tags {name description rank isMediaSpoiler isGeneralSpoiler}
      source
      hashtag
      countryOfOrigin
      mediaListEntry {
        id
        status
        progress
        progressVolumes
        score
        repeat
        notes
        startedAt {year month day}
        completedAt {year month day}
        private
        hiddenFromStatusLists
        customLists
        advancedScores
      }
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
          voiceActors {id name{userPreferred} language image{large}}
          node {id name{userPreferred} image{large}}
        }
      }
    }
    fragment staff on Media {
      staff(page: $staffPage) {
        pageInfo {hasNextPage}
        edges {role node {id name{userPreferred} image{large}}}
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

  static const INFO = 0;
  static const RELATIONS = 1;
  static const SOCIAL = 2;
  static const REL_MEDIA = 0;
  static const REL_CHARACTERS = 1;
  static const REL_STAFF = 2;

  // ***************************************************************************
  // DATA
  // ***************************************************************************

  final int id;
  MediaController(this.id);

  MediaModel? _model;
  int _tab = INFO;
  final _relationsTab = REL_MEDIA.obs;
  final _staffLanguage = 'Japanese'.obs;
  final _availableLanguages = <String>[];
  bool _isLoading = false;
  bool showSpoilerTags = false;

  int get tab => _tab;
  set tab(int val) {
    _tab = val;
    update();
  }

  int get relationsTab => _relationsTab();
  set relationsTab(final int val) {
    _relationsTab.value = val;
    if (val == REL_CHARACTERS &&
            _model!.characters.items.isEmpty &&
            _model!.characters.hasNextPage ||
        val == REL_STAFF &&
            _model!.staff.items.isEmpty &&
            _model!.staff.hasNextPage) _fetchRelationPage();
  }

  bool get isLoading => _isLoading;

  @override
  bool get hasNextPage {
    if (_tab == SOCIAL) return _model?.reviews.hasNextPage ?? false;

    if (_tab == RELATIONS) {
      if (_tab == REL_CHARACTERS)
        return _model?.characters.hasNextPage ?? false;

      if (_tab == REL_STAFF) return _model?.characters.hasNextPage ?? false;
    }

    return false;
  }

  MediaModel? get model => _model;

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
    if (_model != null) return;
    _isLoading = true;

    final result = await Client.request(_mediaQuery, {
      'id': id,
      'withMain': true,
      'withReviews': true,
    });
    if (result == null) return;

    _model = MediaModel(result['Media']);
    update();
    _isLoading = false;
  }

  @override
  Future<void> fetchPage() async =>
      _tab == RELATIONS ? _fetchRelationPage() : _fetchReviewPage();

  Future<void> _fetchRelationPage() async {
    final ofCharacters = _relationsTab() == REL_CHARACTERS;
    _isLoading = true;

    final result = await Client.request(_mediaQuery, {
      'id': id,
      'withCharacters': ofCharacters,
      'withStaff': !ofCharacters,
      'characterPage': _model!.characters.nextPage,
      'staffPage': _model!.staff.nextPage,
    });

    if (result == null) return;
    if (ofCharacters)
      _model!.addCharacters(result['Media'], _availableLanguages);
    else
      _model!.addStaff(result['Media']);
    _isLoading = false;
  }

  Future<void> _fetchReviewPage() async {
    _isLoading = true;

    final result = await Client.request(_mediaQuery, {
      'id': id,
      'withReviews': true,
      'reviewPage': _model!.reviews.nextPage,
    });

    if (result == null) return;
    _model!.addReviews(result['Media']);
    _isLoading = false;
  }

  Future<bool> toggleFavourite() async =>
      await Client.request(
        _model!.info.type == Explorable.anime
            ? _toggleFavouriteAnimeMutation
            : _toggleFavouriteMangaMutation,
        {'id': id},
      ) !=
      null;

  @override
  void onInit() {
    super.onInit();
    fetch();
  }
}
