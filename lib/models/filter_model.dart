import 'package:get/get.dart';
import 'package:otraku/constants/entry_sort.dart';
import 'package:otraku/controllers/tag_group_controller.dart';
import 'package:otraku/utils/settings.dart';

class FilterModel {
  FilterModel._({
    required this.ofAnime,
    required this.ofCollection,
    required this.collectionFilter,
    required this.exploreFilter,
  });

  factory FilterModel.collection(bool ofAnime, CollectionFilterModel model) =>
      FilterModel._(
        ofAnime: ofAnime,
        ofCollection: true,
        collectionFilter: model,
        exploreFilter: null,
      );

  factory FilterModel.explore(bool ofAnime, ExploreFilterModel model) =>
      FilterModel._(
        ofAnime: ofAnime,
        ofCollection: false,
        collectionFilter: null,
        exploreFilter: model,
      );

  final bool ofAnime;
  final bool ofCollection;
  final CollectionFilterModel? collectionFilter;
  final ExploreFilterModel? exploreFilter;

  FilterModel copy() => ofCollection
      ? FilterModel.collection(ofAnime, collectionFilter!.copy())
      : FilterModel.explore(ofAnime, exploreFilter!.copy());

  void clear() => ofCollection
      ? collectionFilter!.clear(refresh: true)
      : exploreFilter!.clear(refresh: true);

  void assign(FilterModel other) {
    if (ofCollection != other.ofCollection) return;
    ofCollection
        ? collectionFilter!.assign(other.collectionFilter!)
        : exploreFilter!.assign(other.exploreFilter!);
  }
}

class CollectionFilterModel {
  CollectionFilterModel(this._onChange, bool ofAnime) {
    sort = ofAnime ? Settings().defaultAnimeSort : Settings().defaultMangaSort;
  }

  final void Function(bool)? _onChange;
  final List<String> statuses = [];
  final List<String> formats = [];
  final List<String> genreIn = [];
  final List<String> genreNotIn = [];
  final List<String> tagIn = [];
  final List<String> tagNotIn = [];
  final List<int> tagIdIn = [];
  final List<int> tagIdNotIn = [];
  String? country;
  late EntrySort sort;

  CollectionFilterModel copy() {
    final model = CollectionFilterModel(null, true);
    model.sort = sort;
    model.country = country;
    model.statuses.addAll(statuses);
    model.formats.addAll(formats);
    model.genreIn.addAll(genreIn);
    model.genreNotIn.addAll(genreNotIn);
    model.tagIn.addAll(tagIn);
    model.tagNotIn.addAll(tagNotIn);
    return model;
  }

  void clear({bool refresh = false}) {
    country = null;
    statuses.clear();
    formats.clear();
    genreIn.clear();
    genreNotIn.clear();
    tagIn.clear();
    tagNotIn.clear();
    tagIdIn.clear();
    tagIdNotIn.clear();
    if (refresh) _onChange?.call(false);
  }

  void assign(CollectionFilterModel other) {
    final mustSort = sort != other.sort;
    sort = other.sort;
    country = other.country;
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
    tagIdIn.clear();
    tagIdNotIn.clear();
    final tags = Get.find<TagGroupController>().model;
    if (tags != null) {
      for (final t in tagIn) {
        final i = tags.indices[t];
        if (i == null) continue;
        tagIdIn.add(tags.ids[i]);
      }
      for (final t in tagNotIn) {
        final i = tags.indices[t];
        if (i == null) continue;
        tagIdNotIn.add(tags.ids[i]);
      }
    }
    _onChange?.call(mustSort);
  }
}

class ExploreFilterModel {
  ExploreFilterModel(this._onChange);

  final void Function()? _onChange;
  final List<String> statuses = [];
  final List<String> formats = [];
  final List<String> genreIn = [];
  final List<String> genreNotIn = [];
  final List<String> tagIn = [];
  final List<String> tagNotIn = [];
  String? country;
  bool? onList;
  String sort = Settings().defaultExploreSort.name;

  ExploreFilterModel copy() {
    final model = ExploreFilterModel(null);
    model.sort = sort;
    model.onList = onList;
    model.country = country;
    model.statuses.addAll(statuses);
    model.formats.addAll(formats);
    model.genreIn.addAll(genreIn);
    model.genreNotIn.addAll(genreNotIn);
    model.tagIn.addAll(tagIn);
    model.tagNotIn.addAll(tagNotIn);
    return model;
  }

  void clear({bool refresh = false}) {
    onList = null;
    country = null;
    statuses.clear();
    formats.clear();
    genreIn.clear();
    genreNotIn.clear();
    tagIn.clear();
    tagNotIn.clear();
    if (refresh) _onChange?.call();
  }

  void assign(ExploreFilterModel other) {
    sort = other.sort;
    onList = other.onList;
    country = other.country;
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
    _onChange?.call();
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{'sort': sort};

    if (statuses.isNotEmpty) map['status_in'] = statuses;
    if (formats.isNotEmpty) map['format_in'] = formats;
    if (genreIn.isNotEmpty) map['genre_in'] = genreIn;
    if (genreNotIn.isNotEmpty) map['genre_not_in'] = genreNotIn;
    if (tagIn.isNotEmpty) map['tag_in'] = tagIn;
    if (tagNotIn.isNotEmpty) map['tag_not_in'] = tagNotIn;
    if (country != null) map['countryOfOrigin'] = country;
    if (onList != null) map['onList'] = onList;

    return map;
  }
}
