import 'package:flutter/foundation.dart';

class StudioData {
  final int id;
  final int favourites;
  final bool isFavourite;

  StudioData({
    @required this.id,
    @required this.isFavourite,
    @required this.favourites,
  });

  factory StudioData.studio(Map<String, dynamic> map, int id) => StudioData(
        id: id,
        isFavourite: map['isFavourite'],
        favourites: map['favourites'],
      );
}
