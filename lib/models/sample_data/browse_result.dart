import 'package:flutter/foundation.dart';
import 'package:otraku/enums/browsable_enum.dart';

class BrowseResult {
  final int id;
  final String title;
  final String imageUrl;
  final Browsable browsable;

  BrowseResult({
    @required this.id,
    @required this.title,
    @required this.browsable,
    this.imageUrl,
  });
}
