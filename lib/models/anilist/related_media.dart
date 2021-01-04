import 'package:flutter/foundation.dart';
import 'package:otraku/enums/browsable.dart';
import 'package:otraku/models/tile_data.dart';

class RelatedMedia extends TileData {
  final String relationType;
  final String format;
  final String status;

  RelatedMedia({
    @required this.relationType,
    @required this.format,
    @required this.status,
    @required int id,
    @required String title,
    @required String imageUrl,
    @required Browsable browsable,
  }) : super(id: id, title: title, imageUrl: imageUrl, browsable: browsable);
}
