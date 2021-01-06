import 'package:flutter/foundation.dart';
import 'package:otraku/enums/browsable.dart';
import 'package:otraku/models/model_helpers.dart';

class Person {
  final int id;
  final Browsable browsable;
  final String fullName;
  final List<String> altNames;
  final String imageUrl;
  final String description;
  final int favourites;
  final bool isFavourite;

  Person._({
    @required this.id,
    @required this.browsable,
    @required this.fullName,
    @required this.altNames,
    @required this.imageUrl,
    @required this.description,
    @required this.isFavourite,
    @required this.favourites,
  });

  factory Person(Map<String, dynamic> map, int id, Browsable browsable) {
    List<String> altNames = (map['name']['alternative'] as List<dynamic>)
        .map((a) => a.toString())
        .toList();
    if (map['name']['native'] != null)
      altNames.insert(0, map['name']['native']);

    return Person._(
      id: id,
      browsable: Browsable.staff,
      isFavourite: map['isFavourite'],
      favourites: map['favourites'],
      fullName: map['name']['full'],
      altNames: altNames,
      imageUrl: map['image']['large'],
      description: clearHtml(map['description']),
    );
  }
}
