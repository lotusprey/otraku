import 'package:flutter/foundation.dart';
import 'package:otraku/enums/browsable_enum.dart';
import 'package:otraku/models/page_item_data.dart';

class CharacterData extends PageItemData {
  final String fullName;
  final List<String> altNames;
  final String imageUrl;
  final String description;

  CharacterData({
    @required this.fullName,
    @required this.altNames,
    @required this.imageUrl,
    @required this.description,
    @required id,
    @required isFavourite,
    @required favourites,
  }) : super(
          id: id,
          isFavourite: isFavourite,
          favourites: favourites,
          browsable: Browsable.characters,
        );
}
