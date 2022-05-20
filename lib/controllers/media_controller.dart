import 'package:otraku/constants/explorable.dart';
import 'package:otraku/settings/user_settings.dart';
import 'package:otraku/utils/client.dart';
import 'package:otraku/utils/graphql.dart';
import 'package:otraku/models/media_model.dart';
import 'package:otraku/utils/scrolling_controller.dart';

class MediaController extends ScrollingController {
  // Tabs.
  static const INFO = 0;
  static const OTHER = 1;
  static const PEOPLE = 2;
  static const SOCIAL = 3;

  // GetBuilder ids.
  static const ID_BASE = 0;
  static const ID_OUTER = 1;
  static const ID_INNER = 2;

  MediaController(this.id, this.settings);

  final int id;
  final UserSettings settings;
  MediaModel? _model;
  int _tab = INFO;
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

  int get tab => _tab;
  set tab(int val) {
    _tab = val;
    update([ID_OUTER]);
  }

  bool get otherTabToggled => _otherTabToggled;
  set otherTabToggled(bool val) {
    _otherTabToggled = val;
    update([ID_INNER]);
  }

  bool get peopleTabToggled => _peopleTabToggled;
  set peopleTabToggled(bool val) {
    _peopleTabToggled = val;
    update([ID_OUTER]);
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

    final result = await Client.request(GqlQuery.media, {
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

  @override
  Future<void> fetchPage() async {
    if (_model == null) return;

    switch (_tab) {
      case OTHER:
        if (!_otherTabToggled || !_model!.recommendations.hasNextPage) return;

        final result = await Client.request(GqlQuery.media, {
          'id': id,
          'withRecommendations': true,
          'recommendationPage': _model!.recommendations.nextPage,
        });

        if (result == null) return;
        _model!.addRecommendations(result['Media']);

        update([ID_INNER]);
        return;
      case PEOPLE:
        if (!_peopleTabToggled) {
          if (!_model!.characters.hasNextPage) return;

          final result = await Client.request(GqlQuery.media, {
            'id': id,
            'withCharacters': true,
            'characterPage': _model!.characters.nextPage,
          });

          if (result == null) return;
          _model!.addCharacters(result['Media'], languages);
        } else {
          if (!_model!.staff.hasNextPage) return;

          final result = await Client.request(GqlQuery.media, {
            'id': id,
            'withStaff': true,
            'staffPage': _model!.staff.nextPage,
          });

          if (result == null) return;
          _model!.addStaff(result['Media']);
        }
        update([ID_INNER]);
        return;
      case SOCIAL:
        if (_socialTabToggled || !_model!.reviews.hasNextPage) return;

        final result = await Client.request(GqlQuery.media, {
          'id': id,
          'withReviews': true,
          'reviewPage': _model!.reviews.nextPage,
        });

        if (result == null) return;
        _model!.addReviews(result['Media']);

        update([ID_INNER]);
        return;
      default:
        return;
    }
  }

  Future<bool> toggleFavourite() async {
    final data = await Client.request(
      GqlMutation.toggleFavourite,
      {(_model!.info.type == Explorable.anime ? 'anime' : 'manga'): id},
    );
    if (data != null) _model!.info.isFavourite = !_model!.info.isFavourite;
    return _model!.info.isFavourite;
  }

  Future<bool> rateRecommendation(int recommendationId, bool? rating) async {
    final data = await Client.request(GqlMutation.rateRecommendation, {
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
