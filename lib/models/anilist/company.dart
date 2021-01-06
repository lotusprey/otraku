import 'package:flutter/foundation.dart';
import 'package:otraku/enums/browsable.dart';

class Company {
  final int id;
  final Browsable browsable;
  final int favourites;
  final bool isFavourite;

  Company({
    @required this.id,
    @required this.isFavourite,
    @required this.favourites,
    @required this.browsable,
  });

  factory Company.studio(Map<String, dynamic> map, int id) => Company(
        id: id,
        browsable: Browsable.studio,
        isFavourite: map['isFavourite'],
        favourites: map['favourites'],
      );
}
