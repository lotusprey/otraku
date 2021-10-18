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
      siteUrl
      countryOfOrigin
      rankings {rank type year season allTime}
      stats {scoreDistribution {score amount} statusDistribution {status amount}}
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

  // Tabs.
  static const INFO = 0;
  static const OTHER = 1;
  static const SOCIAL = 2;

  // Tabs of 'Other'.
  static const RELATIONS = 0;
  static const CHARACTERS = 1;
  static const STAFF = 2;

  // Tabs of 'Social'.
  static const REVIEWS = 0;
  static const STATS = 1;

  // GetBuilder ids.
  static const ID_BASE = 0;
  static const ID_OUTER = 1;
  static const ID_INNER = 2;

  // ***************************************************************************
  // DATA
  // ***************************************************************************

  final int id;
  MediaController(this.id);

  MediaModel? _model;
  int _tab = INFO;
  int _otherTab = RELATIONS;
  int _socialTab = REVIEWS;
  int _language = 0;
  bool showSpoilerTags = false;
  final _availableLanguages = <String>[];

  List<String> get availableLanguages => [..._availableLanguages];

  MediaModel? get model => _model;

  int get language => _language;
  set language(int val) {
    _language = val;
    update([ID_INNER]);
  }

  int get tab => _tab;
  set tab(int val) {
    _tab = val;
    update([ID_OUTER]);
  }

  int get otherTab => _otherTab;
  set otherTab(final int val) {
    _otherTab = val;
    update([ID_OUTER]);
  }

  int get socialTab => _socialTab;
  set socialTab(final int val) {
    _socialTab = val;
    update([ID_INNER]);
  }

  @override
  bool get hasNextPage {
    if (_tab == OTHER) {
      if (_tab == CHARACTERS) return _model?.characters.hasNextPage ?? false;
      if (_tab == STAFF) return _model?.characters.hasNextPage ?? false;
    }

    if (_tab == SOCIAL && _socialTab == REVIEWS)
      return _model?.reviews.hasNextPage ?? false;

    return false;
  }

  // ***************************************************************************
  // FETCHING
  // ***************************************************************************

  Future<void> fetch() async {
    if (_model != null) return;

    final result = await Client.request(_mediaQuery, {
      'id': id,
      'withMain': true,
      'withCharacters': true,
      'withStaff': true,
      'withReviews': true,
    });
    if (result == null) return;

    _model = MediaModel(result['Media']);
    _model!.addCharacters(result['Media'], _availableLanguages);
    _model!.addStaff(result['Media']);

    update([ID_BASE]);
  }

  @override
  Future<void> fetchPage() async =>
      _tab == OTHER ? _fetchOtherPage() : _fetchReviewPage();

  Future<void> _fetchOtherPage() async {
    final ofCharacters = _otherTab == CHARACTERS;

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

    update([ID_INNER]);
  }

  Future<void> _fetchReviewPage() async {
    final result = await Client.request(_mediaQuery, {
      'id': id,
      'withReviews': true,
      'reviewPage': _model!.reviews.nextPage,
    });

    if (result == null) return;
    _model!.addReviews(result['Media']);

    update([ID_INNER]);
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
