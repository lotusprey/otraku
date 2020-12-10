import 'package:flutter/foundation.dart';
import 'package:otraku/enums/browsable_enum.dart';
import 'package:otraku/models/sample_data/browse_result.dart';

class RelatedMedia extends BrowseResult {
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
