import 'package:flutter/material.dart';
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
  static const ON_LIST = 'onList';
  static const IS_ADULT = 'isAdult';
  static const SEARCH = 'search';
  static const TYPE = 'type';
  static const SORT = 'sort';
  static const PAGE = 'page';

  final _scrollCtrl = ScrollController();

  ScrollController get scrollCtrl => _scrollCtrl;

  void scrollToTop() {
    if (_scrollCtrl.offset > 100) _scrollCtrl.jumpTo(100);
    _scrollCtrl.animateTo(
      0,
      duration: const Duration(milliseconds: 200),
      curve: Curves.decelerate,
    );
  }

  @override
  void onClose() {
    _scrollCtrl.dispose();
    super.onClose();
  }

  dynamic getFilterWithKey(String key);

  void setFilterWithKey(String key, {dynamic value, bool update = false});

  void clearAllFilters({bool update = true});

  void clearFiltersWithKeys(List<String> keys, {bool update = true});

  bool anyActiveFilterFrom(List<String> keys);
}
