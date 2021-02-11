import 'package:flutter/foundation.dart';
import 'package:otraku/models/browse_result_model.dart';

class Connection extends BrowseResultModel {
  final String subtitle;
  final String caption;
  final List<Connection> others;

  Connection({
    this.others = const [],
    this.subtitle = '',
    this.caption = '',
    @required id,
    @required title,
    @required imageUrl,
    @required browsable,
  }) : super(id: id, title: title, imageUrl: imageUrl, browsable: browsable);
}
