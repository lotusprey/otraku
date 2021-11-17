import 'package:otraku/enums/explorable.dart';
import 'package:otraku/utils/client.dart';
import 'package:otraku/utils/graphql.dart';
import 'package:otraku/utils/overscroll_controller.dart';
import 'package:otraku/models/media_model.dart';

class MediaController extends OverscrollController {
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

  MediaController(this.id);

  final int id;
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

    final result = await Client.request(GqlQuery.media, {
      'id': id,
      'withMain': true,
      'withDetails': true,
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

    final result = await Client.request(GqlQuery.media, {
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
    final result = await Client.request(GqlQuery.media, {
      'id': id,
      'withReviews': true,
      'reviewPage': _model!.reviews.nextPage,
    });

    if (result == null) return;
    _model!.addReviews(result['Media']);

    update([ID_INNER]);
  }

  Future<bool> toggleFavourite() async {
    final data = await Client.request(
      GqlMutation.toggleFavourite,
      {(_model!.info.type == Explorable.anime ? 'anime' : 'manga'): id},
    );
    if (data != null) _model!.info.isFavourite = !_model!.info.isFavourite;
    return _model!.info.isFavourite;
  }

  @override
  void onInit() {
    super.onInit();
    fetch();
  }
}
