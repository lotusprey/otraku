import 'package:get/get.dart';
import 'package:otraku/constants/explorable.dart';
import 'package:otraku/settings/user_settings.dart';
import 'package:otraku/utils/api.dart';
import 'package:otraku/utils/graphql.dart';
import 'package:otraku/models/media_model.dart';

class MediaController extends GetxController {
  // GetBuilder ids.
  static const ID_BASE = 0;
  static const ID_INNER = 1;
  static const ID_LANG = 2;

  MediaController(this.id, this.settings);

  final int id;
  final UserSettings settings;
  MediaModel? _model;
  bool _otherTabToggled = false;
  bool _peopleTabToggled = false;
  bool _socialTabToggled = false;
  int _langIndex = 0;
  bool showSpoilerTags = false;
  final languages = <String>[];

  MediaModel? get model => _model;

  int get langIndex => _langIndex;
  set langIndex(int val) {
    _langIndex = val;
    update([ID_INNER]);
  }

  bool get otherTabToggled => _otherTabToggled;
  set otherTabToggled(bool val) {
    _otherTabToggled = val;
    update([ID_INNER]);
  }

  bool get peopleTabToggled => _peopleTabToggled;
  set peopleTabToggled(bool val) {
    _peopleTabToggled = val;
    update([ID_INNER, ID_LANG]);
  }

  bool get socialTabToggled => _socialTabToggled;
  set socialTabToggled(bool val) {
    _socialTabToggled = val;
    update([ID_INNER]);
  }

  // ***************************************************************************
  // FETCHING
  // ***************************************************************************

  Future<void> fetch() async {
    if (_model != null) return;

    final result = await Api.request(GqlQuery.media, {
      'id': id,
      'withMain': true,
      'withDetails': true,
      'withRecommendations': true,
      'withCharacters': true,
      'withStaff': true,
      'withReviews': true,
    });
    if (result == null) return;

    _model = MediaModel(result['Media'], settings);
    _model!.addRecommendations(result['Media']);
    _model!.addCharacters(result['Media'], languages);
    _model!.addStaff(result['Media']);

    update([ID_BASE]);
  }

  Future<void> fetchRecommendations() async {
    if (!_otherTabToggled || !_model!.recommendations.hasNextPage) return;

    final result = await Api.request(GqlQuery.media, {
      'id': id,
      'withRecommendations': true,
      'recommendationPage': _model!.recommendations.nextPage,
    });

    if (result == null) return;
    _model!.addRecommendations(result['Media']);

    update([ID_INNER]);
  }

  Future<void> fetchCharacters() async {
    if (_peopleTabToggled || !_model!.characters.hasNextPage) return;

    final result = await Api.request(GqlQuery.media, {
      'id': id,
      'withCharacters': true,
      'characterPage': _model!.characters.nextPage,
    });

    if (result == null) return;
    _model!.addCharacters(result['Media'], languages);

    update([ID_INNER]);
  }

  Future<void> fetchStaff() async {
    if (!_peopleTabToggled || !_model!.staff.hasNextPage) return;

    final result = await Api.request(GqlQuery.media, {
      'id': id,
      'withStaff': true,
      'staffPage': _model!.staff.nextPage,
    });

    if (result == null) return;
    _model!.addStaff(result['Media']);

    update([ID_INNER]);
  }

  Future<void> fetchReviews() async {
    if (_socialTabToggled || !_model!.reviews.hasNextPage) return;

    final result = await Api.request(GqlQuery.media, {
      'id': id,
      'withReviews': true,
      'reviewPage': _model!.reviews.nextPage,
    });

    if (result == null) return;
    _model!.addReviews(result['Media']);

    update([ID_INNER]);
  }

  Future<bool> toggleFavourite() async {
    final data = await Api.request(
      GqlMutation.toggleFavorite,
      {(_model!.info.type == Explorable.anime ? 'anime' : 'manga'): id},
    );
    if (data != null) _model!.info.isFavourite = !_model!.info.isFavourite;
    return _model!.info.isFavourite;
  }

  Future<bool> rateRecommendation(int recommendationId, bool? rating) async {
    final data = await Api.request(GqlMutation.rateRecommendation, {
      'id': id,
      'recommendedId': recommendationId,
      'rating': rating == null
          ? 'NO_RATING'
          : rating
              ? 'RATE_UP'
              : 'RATE_DOWN',
    });
    return data != null;
  }

  @override
  void onInit() {
    super.onInit();
    fetch();
  }
}
