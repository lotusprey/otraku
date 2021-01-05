import 'package:flutter/foundation.dart';
import 'package:otraku/enums/browsable.dart';

import '../page_object.dart';

class Person extends PageObject {
  final String fullName;
  final List<String> altNames;
  final String imageUrl;
  final String description;

  Person._({
    @required this.fullName,
    @required this.altNames,
    @required this.imageUrl,
    @required this.description,
    @required id,
    @required browsable,
    @required isFavourite,
    @required favourites,
  }) : super(
          id: id,
          browsable: browsable,
          isFavourite: isFavourite,
          favourites: favourites,
        );

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
      description:
          map['description'].toString().replaceAll(RegExp(r'<[^>]*>'), ''),
    );
  }
}
