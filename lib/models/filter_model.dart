import 'package:get/get.dart';
import 'package:otraku/constants/entry_sort.dart';
import 'package:otraku/constants/media_sort.dart';
import 'package:otraku/controllers/tag_group_controller.dart';
import 'package:otraku/utils/settings.dart';

abstract class FilterModel<T extends Enum> {
  FilterModel(this._ofAnime, this.sort);

  final List<String> statuses = [];
  final List<String> formats = [];
  final List<String> genreIn = [];
  final List<String> genreNotIn = [];
  final List<String> tagIn = [];
  final List<String> tagNotIn = [];
  String? country;
  T sort;

  bool _ofAnime;
  bool get ofAnime => _ofAnime;

  void clear(bool refresh) {
    statuses.clear();
    formats.clear();
    genreIn.clear();
    genreNotIn.clear();
    tagIn.clear();
    tagNotIn.clear();
    country = null;
  }

  void copy(covariant FilterModel<T> other) {
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
  }
}

class CollectionFilterModel extends FilterModel<EntrySort> {
  CollectionFilterModel(bool ofAnime, this.onChange)
      : super(
          ofAnime,
          ofAnime ? Settings().defaultAnimeSort : Settings().defaultMangaSort,
        );

  final List<int> tagIdIn = [];
  final List<int> tagIdNotIn = [];
  final void Function(bool)? onChange;

  @override
  void clear(bool refresh) {
    super.clear(refresh);
    tagIdIn.clear();
    tagIdNotIn.clear();
    if (refresh) onChange?.call(false);
  }

  @override
  void copy(covariant CollectionFilterModel other) {
    final mustSort = sort != other.sort;
    super.copy(other);
    tagIdIn.clear();
    tagIdNotIn.clear();
    if (onChange == null) {
      tagIdIn.addAll(other.tagIdIn);
      tagIdNotIn.addAll(other.tagIdNotIn);
      return;
    }
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
    onChange?.call(mustSort);
  }
}

class ExploreFilterModel extends FilterModel<MediaSort> {
  ExploreFilterModel(bool ofAnime, this.onChange)
      : super(ofAnime, Settings().defaultExploreSort);

  bool? onList;
  final void Function()? onChange;

  set ofAnime(bool val) {
    _ofAnime = val;
    formats.clear();
  }

  @override
  void clear(bool refresh) {
    super.clear(refresh);
    onList = null;
    if (refresh) onChange?.call();
  }

  @override
  void copy(covariant ExploreFilterModel other) {
    super.copy(other);
    onList = other.onList;
    onChange?.call();
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{'sort': sort.name};

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
