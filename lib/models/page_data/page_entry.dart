import 'package:flutter/foundation.dart';
import 'package:otraku/enums/browsable_enum.dart';

class PageEntry {
  final int id;
  final Browsable browsable;
  final int favourites;
  bool isFavourite;

  PageEntry({
    @required this.id,
    @required this.isFavourite,
    @required this.favourites,
    @required this.browsable,
  });
}
