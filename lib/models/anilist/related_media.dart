import 'package:flutter/foundation.dart';
import 'package:otraku/enums/browsable.dart';
import 'package:otraku/enums/enum_helper.dart';
import 'package:otraku/models/tile_data.dart';

class RelatedMedia extends TileData {
  final String relationType;
  final String format;
  final String status;

  RelatedMedia._({
    @required this.relationType,
    @required this.format,
    @required this.status,
    @required int id,
    @required String title,
    @required String imageUrl,
    @required Browsable browsable,
  }) : super(id: id, title: title, imageUrl: imageUrl, browsable: browsable);

  factory RelatedMedia(Map<String, dynamic> map) => RelatedMedia._(
        id: map['node']['id'],
        title: map['node']['title']['userPreferred'],
        relationType: clarifyEnum(map['mapType']),
        format: clarifyEnum(map['node']['format']),
        status: clarifyEnum(map['node']['status']),
        imageUrl: map['node']['coverImage']['large'],
        browsable:
            map['node']['type'] == 'ANIME' ? Browsable.anime : Browsable.manga,
      );
}
