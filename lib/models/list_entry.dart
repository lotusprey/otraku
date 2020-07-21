import 'package:flutter/foundation.dart';

class ListEntry {
  final int id;
  final String title;
  final String cover;
  final String format;
  final double score;

  ListEntry({
    @required this.id,
    @required this.title,
    @required this.cover,
    @required this.format,
    @required this.score,
  });
}
