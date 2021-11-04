import 'package:get/get.dart';

// Base class for filterable groups like Explorer and Collection
abstract class Filterable extends GetxController {
  // Filter keys. Compatible with the AL API variables.
  static const STATUS_IN = 'status_in';
  static const FORMAT_IN = 'format_in';
  static const ID_NOT_IN = 'id_not_in';
  static const GENRE_IN = 'genre_in';
  static const GENRE_NOT_IN = 'genre_not_in';
  static const TAG_IN = 'tag_in';
  static const TAG_NOT_IN = 'tag_not_in';
  static const COUNTRY = 'countryOfOrigin';
  static const ON_LIST = 'onList';
  static const IS_ADULT = 'isAdult';
  static const IS_BIRTHDAY = 'isBirthday';
  static const SEARCH = 'search';
  static const TYPE = 'type';
  static const SORT = 'sort';
  static const PAGE = 'page';

  dynamic getFilterWithKey(String key);

  void setFilterWithKey(String key, {dynamic value, bool update = false});

  void clearAllFilters({bool update = true});

  void clearFiltersWithKeys(List<String> keys, {bool update = true});

  bool anyActiveFilterFrom(List<String> keys);
}
