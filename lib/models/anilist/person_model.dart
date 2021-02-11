import 'package:flutter/foundation.dart';
import 'package:otraku/helpers/fn_helper.dart';

class PersonModel {
  final int id;
  final String fullName;
  final List<String> altNames;
  final String imageUrl;
  final String description;
  final int favourites;
  final bool isFavourite;

  PersonModel._({
    @required this.id,
    @required this.fullName,
    @required this.altNames,
    @required this.imageUrl,
    @required this.description,
    @required this.isFavourite,
    @required this.favourites,
  });

  factory PersonModel(final Map<String, dynamic> map) {
    List<String> altNames = (map['name']['alternative'] as List<dynamic>)
        .map((a) => a.toString())
        .toList();
    if (map['name']['native'] != null)
      altNames.insert(0, map['name']['native']);

    return PersonModel._(
      id: map['id'],
      isFavourite: map['isFavourite'],
      favourites: map['favourites'],
      fullName: map['name']['full'],
      altNames: altNames,
      imageUrl: map['image']['large'],
      description: FnHelper.clearHtml(map['description']),
    );
  }

  factory PersonModel.studio(final Map<String, dynamic> map) => PersonModel._(
        id: map['id'],
        isFavourite: map['isFavourite'],
        favourites: map['favourites'],
        fullName: null,
        altNames: null,
        imageUrl: null,
        description: null,
      );
}
