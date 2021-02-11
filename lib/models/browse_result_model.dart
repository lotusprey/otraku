import 'package:flutter/foundation.dart';
import 'package:otraku/enums/browsable.dart';

class BrowseResultModel {
  final int id;
  final String title;
  final String subtitle;
  final String caption;
  final String imageUrl;
  final Browsable browsable;

  BrowseResultModel({
    @required this.id,
    @required this.title,
    @required this.browsable,
    this.subtitle,
    this.caption,
    this.imageUrl,
  });
}
