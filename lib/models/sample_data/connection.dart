import 'package:flutter/foundation.dart';
import 'package:otraku/enums/browsable_enum.dart';
import 'package:otraku/models/sample_data/browse_result.dart';

class Connection extends BrowseResult {
  final String text;
  final List<Connection> others;
  final Browsable browsable;

  Connection({
    this.others = const [],
    this.text = '',
    @required this.browsable,
    @required id,
    @required title,
    @required imageUrl,
  }) : super(id: id, title: title, imageUrl: imageUrl);
}
