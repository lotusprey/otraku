import 'package:get/get.dart';
import 'package:otraku/enums/browsable.dart';
import 'package:otraku/helpers/fn_helper.dart';
import 'package:otraku/helpers/graph_ql.dart';
import 'package:otraku/helpers/scroll_x_controller.dart';
import 'package:otraku/models/anilist/related_review_model.dart';
import 'package:otraku/models/loadable_list.dart';
import 'package:otraku/models/anilist/media_overview_model.dart';
import 'package:otraku/models/connection.dart';
import 'package:otraku/models/anilist/related_media_model.dart';

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
  final _overview = Rx<MediaOverviewModel>();
  final _otherMedia = List<RelatedMediaModel>().obs;
  final _characters = Rx<LoadableList<Connection>>();
  final _staff = Rx<LoadableList<Connection>>();
  final _reviews = Rx<LoadableList<RelatedReviewModel>>();
  final _staffLanguage = 'Japanese'.obs;
  final List<String> _availableLanguages = [];

  int get tab => _tab();

  set tab(int value) => _tab.value = value;

  int get relationsTab => _relationsTab();

  set relationsTab(int value) {
    _relationsTab.value = value;
    if (value == REL_CHARACTERS && _characters() == null)
      fetchRelationPage(true);
    if (value == REL_STAFF && _staff() == null) fetchRelationPage(false);
  }

  MediaOverviewModel get overview => _overview();

  List<RelatedMediaModel> get otherMedia => _otherMedia();

  LoadableList get characters => _characters();

  LoadableList get staff => _staff();

  LoadableList<RelatedReviewModel> get reviews => _reviews();

  String get staffLanguage => _staffLanguage();

  set staffLanguage(String value) => _staffLanguage.value = value;

  int get languageIndex {
    final index = _availableLanguages.indexOf(_staffLanguage());
    if (index != -1) return index;
    return 0;
  }

  List<String> get availableLanguages => [..._availableLanguages];

  // ***************************************************************************
  // FETCHING
  // ***************************************************************************

  Future<void> fetch() async {
    if (_overview.value != null) return;

    final result = await GraphQL.request(_mediaQuery, {
      'id': _id,
      'withMain': true,
      'withReviews': true,
    });

    if (result == null) return null;

    final data = result['Media'];
    _overview(MediaOverviewModel(data));

    final List<RelatedMediaModel> mediaRel = [];
    for (final relation in data['relations']['edges'])
      mediaRel.add(RelatedMediaModel(relation));

    _otherMedia.addAll(mediaRel);

    final List<RelatedReviewModel> revs = [];
    for (final r in data['reviews']['nodes']) revs.add(RelatedReviewModel(r));
    _reviews(LoadableList(revs, data['reviews']['pageInfo']['hasNextPage']));
  }

  Future<void> fetchRelationPage(bool ofCharacters) async {
    if (ofCharacters && !(_characters()?.hasNextPage ?? true)) return;
    if (!ofCharacters && !(_staff()?.hasNextPage ?? true)) return;

    final result = await GraphQL.request(_mediaQuery, {
      'id': _id,
      'withCharacters': ofCharacters,
      'withStaff': !ofCharacters,
      'characterPage': _characters()?.nextPage,
      'staffPage': _staff()?.nextPage,
    });

    if (result == null) return;
    final data = result['Media'];

    final List<Connection> items = [];
    if (ofCharacters) {
      for (final connection in data['characters']['edges']) {
        final List<Connection> voiceActors = [];

        for (final va in connection['voiceActors']) {
          final language = FnHelper.clarifyEnum(va['language']);
          if (!_availableLanguages.contains(language))
            _availableLanguages.add(language);

          voiceActors.add(Connection(
            id: va['id'],
            title: va['name']['full'],
            imageUrl: va['image']['large'],
            browsable: Browsable.staff,
            text2: language,
          ));
        }

        items.add(Connection(
          id: connection['node']['id'],
          title: connection['node']['name']['full'],
          text2: FnHelper.clarifyEnum(connection['role']),
          imageUrl: connection['node']['image']['large'],
          others: voiceActors,
          browsable: Browsable.character,
        ));
      }

      if (_characters() == null)
        _characters(
          LoadableList(items, data['characters']['pageInfo']['hasNextPage']),
        );
      else
        _characters.update(
          (c) => c.append(items, data['characters']['pageInfo']['hasNextPage']),
        );
    } else {
      for (final connection in data['staff']['edges'])
        items.add(Connection(
          id: connection['node']['id'],
          title: connection['node']['name']['full'],
          text2: connection['role'],
          imageUrl: connection['node']['image']['large'],
          browsable: Browsable.staff,
        ));

      if (_staff() == null)
        _staff(
          LoadableList(items, data['staff']['pageInfo']['hasNextPage']),
        );
      else
        _staff.update(
          (s) => s.append(items, data['staff']['pageInfo']['hasNextPage']),
        );
    }
  }

  Future<void> fetchReviewPage() async {
    if (!_reviews().hasNextPage) return;

    final result = await GraphQL.request(_mediaQuery, {
      'id': _id,
      'withReviews': true,
      'reviewPage': _reviews()?.nextPage,
    });

    if (result == null) return;

    final List<RelatedReviewModel> items = [];
    for (final r in result['reviews']['nodes'])
      items.add(RelatedReviewModel(r));
    _reviews.update(
      (r) => r.append(items, result['reviews']['pageInfo']['hasNextPage']),
    );
  }

  Future<bool> toggleFavourite() async =>
      await GraphQL.request(
        _overview().browsable == Browsable.anime
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
