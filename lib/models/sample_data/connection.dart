import 'package:flutter/foundation.dart';
import 'package:otraku/models/sample_data/browse_result.dart';

class Connection extends BrowseResult {
  final String text;
  final List<Connection> others;

  Connection({
    this.others = const [],
    this.text = '',
    @required id,
    @required title,
    @required imageUrl,
    @required browsable,
  }) : super(id: id, title: title, imageUrl: imageUrl, browsable: browsable);
}
