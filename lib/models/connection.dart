import 'package:flutter/foundation.dart';
import 'package:otraku/models/browse_result_model.dart';

class Connection extends BrowseResultModel {
  final String text2;
  final String text3;
  final List<Connection> others;

  Connection({
    this.others = const [],
    this.text2 = '',
    this.text3 = '',
    @required id,
    @required title,
    @required imageUrl,
    @required browsable,
  }) : super(id: id, text1: title, imageUrl: imageUrl, browsable: browsable);
}
