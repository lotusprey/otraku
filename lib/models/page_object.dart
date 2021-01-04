import 'package:flutter/foundation.dart';
import 'package:otraku/enums/browsable.dart';

class PageObject {
  final int id;
  final Browsable browsable;
  final int favourites;
  bool isFavourite;

  PageObject({
    @required this.id,
    @required this.isFavourite,
    @required this.favourites,
    @required this.browsable,
  });
}
