import 'package:otraku/constants/entry_sort.dart';
import 'package:otraku/constants/explorable.dart';
import 'package:otraku/models/tag_collection_model.dart';
import 'package:otraku/utils/settings.dart';

/// Called on certain changes. The parameters specify the type of change.
/// [content] - main content of the view should be updated.
/// [frame]   - header or FAB should be updated.
/// [meta]    - additional behind the scene changes.
///             [CollectionFilterModel] - sort entries.
///             [ExploreFilterModel]    - trigger debounce for search.
typedef OnFilterChange = void Function({bool content, bool frame, bool meta});

// Holds filter data for collections and explore tab.
abstract class FilterModel {
  FilterModel(this._onChange, this._type);

  // Called when certain fields change.
  final OnFilterChange _onChange;

  final List<String> statuses = [];
  final List<String> formats = [];
  final List<String> genreIn = [];
  final List<String> genreNotIn = [];
  final List<String> tagIn = [];
  final List<String> tagNotIn = [];
  String? country;

  String _search = '';
  String get search => _search;

  var _type = Explorable.anime;
  Explorable get type => _type;

  void refresh() => _onChange(content: true);

  // Clear general filters.
  void clear() {
    statuses.clear();
    formats.clear();
    genreIn.clear();
    genreNotIn.clear();
    tagIn.clear();
    tagNotIn.clear();
    country = null;
  }

  // Copy data to another object.
  FilterModel _copy(FilterModel other) {
    other.statuses.addAll(statuses);
    other.formats.addAll(formats);
    other.genreIn.addAll(genreIn);
    other.genreNotIn.addAll(genreNotIn);
    other.tagIn.addAll(tagIn);
    other.tagNotIn.addAll(tagNotIn);
    other.country = country;
    return other;
  }

  // Assign fields from an object.
  void assign(FilterModel other, TagCollectionModel tags) {
    statuses.clear();
    statuses.addAll(other.statuses);
    formats.clear();
    formats.addAll(other.formats);
    genreIn.clear();
    genreIn.addAll(other.genreIn);
    genreNotIn.clear();
    genreNotIn.addAll(other.genreNotIn);
    tagIn.clear();
    tagIn.addAll(other.tagIn);
    tagNotIn.clear();
    tagNotIn.addAll(other.tagNotIn);
    country = other.country;
  }
}

class CollectionFilterModel extends FilterModel {
  CollectionFilterModel._({
    required this.sort,
    required bool ofAnime,
    required OnFilterChange onChange,
  }) : super(onChange, ofAnime ? Explorable.anime : Explorable.manga);

  factory CollectionFilterModel(bool ofAnime, OnFilterChange onChange) {
    return CollectionFilterModel._(
      sort: ofAnime ? Settings().defaultAnimeSort : Settings().defaultMangaSort,
      ofAnime: ofAnime,
      onChange: onChange,
    );
  }

  EntrySort sort;
  final List<int> tagIdIn = [];
  final List<int> tagIdNotIn = [];

  bool get ofAnime => _type == Explorable.anime;

  String get typeName => _type == Explorable.anime ? 'ANIME' : 'MANGA';

  set search(String val) {
    val = val.trim();
    if (_search == val) return;
    _search = val;
    _onChange(content: true);
  }

  @override
  void clear() {
    super.clear();
    tagIdIn.clear();
    tagIdNotIn.clear();
  }

  CollectionFilterModel copy() {
    final other = CollectionFilterModel._(
      sort: sort,
      ofAnime: ofAnime,
      onChange: _onChange,
    );
    _copy(other);
    return other;
  }

  @override
  void assign(FilterModel other, TagCollectionModel tags) {
    super.assign(other, tags);
    if (other is! CollectionFilterModel) return;

    tagIdIn.clear();
    tagIdNotIn.clear();
    for (final t in tagIn) {
      final index = tags.indices[t];
      if (index == null) continue;
      tagIdIn.add(tags.ids[index]);
    }
    for (final t in tagNotIn) {
      final index = tags.indices[t];
      if (index == null) continue;
      tagIdNotIn.add(tags.ids[index]);
    }

    if (sort != other.sort) {
      sort = other.sort;
      _onChange(content: true, meta: true);
    } else {
      _onChange(content: true);
    }
  }
}

class ExploreFilterModel extends FilterModel {
  ExploreFilterModel._({
    required this.sort,
    required Explorable type,
    required OnFilterChange onChange,
  }) : super(onChange, type);

  factory ExploreFilterModel(OnFilterChange onChange) {
    return ExploreFilterModel._(
      sort: Settings().defaultExploreSort.name,
      type: Settings().defaultExplorable,
      onChange: onChange,
    );
  }

  int page = 1;
  String sort;
  bool? onList;
  bool? isAdult;

  bool _isBirthday = false;
  bool get isBirthday => _isBirthday;
  set isBirthday(bool val) {
    if (_isBirthday == val) return;
    _isBirthday = val;
    _onChange(content: true);
  }

  set search(String val) {
    val = val.trim();
    if (_search == val) return;
    _search = val;
    _onChange(content: true, meta: true);
  }

  set type(Explorable val) {
    if (_type == val) return;
    _type = val;
    formats.clear();
    _onChange(content: true, frame: true);
  }

  @override
  void clear() {
    super.clear();
    onList = null;
    page = 1;
  }

  ExploreFilterModel copy() {
    final other = ExploreFilterModel._(
      sort: sort,
      type: _type,
      onChange: _onChange,
    );
    _copy(other);
    other.onList = onList;
    return other;
  }

  @override
  void assign(FilterModel other, TagCollectionModel tags) {
    super.assign(other, tags);
    if (other is! ExploreFilterModel) return;
    page = 1;
    sort = other.sort;
    onList = other.onList;
    _onChange(content: true);
  }

  // Create variables for a GraphQl request.
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'page': page,
      'sort': sort,
      if (search.isNotEmpty) 'search': search,
      if (isAdult != null) 'isAdult': isAdult,
    };

    if (type == Explorable.anime || type == Explorable.manga) {
      if (type == Explorable.anime) map['type'] = 'ANIME';
      if (type == Explorable.manga) map['type'] = 'MANGA';

      if (statuses.isNotEmpty) map['status_in'] = statuses;
      if (formats.isNotEmpty) map['format_in'] = formats;
      if (genreIn.isNotEmpty) map['genre_in'] = genreIn;
      if (genreNotIn.isNotEmpty) map['genre_not_in'] = genreNotIn;
      if (tagIn.isNotEmpty) map['tag_in'] = tagIn;
      if (tagNotIn.isNotEmpty) map['tag_not_in'] = tagNotIn;
      if (country != null) map['countryOfOrigin'] = country;
      if (onList != null) map['onList'] = onList;
    }

    if ((type == Explorable.character || type == Explorable.staff) &&
        _isBirthday) map['isBirthday'] = true;

    return map;
  }
}
