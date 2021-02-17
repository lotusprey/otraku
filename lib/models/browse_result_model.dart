import 'package:flutter/foundation.dart';
import 'package:otraku/enums/browsable.dart';

class BrowseResultModel {
  final int id;
  final String text1;
  final String text2;
  final String text3;
  final String imageUrl;
  final Browsable browsable;

  BrowseResultModel({
    @required this.id,
    @required this.text1,
    @required this.browsable,
    this.text2,
    this.text3,
    this.imageUrl,
  });
}
