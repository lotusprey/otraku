import 'package:flutter/foundation.dart';
import 'package:otraku/enums/browsable_enum.dart';

abstract class PageItemData {
  int id;
  bool isFavourite;
  final int favourites;
  final Browsable browsable;

  PageItemData({
    @required this.id,
    @required this.isFavourite,
    @required this.favourites,
    @required this.browsable,
  });
}
