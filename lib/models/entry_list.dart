import 'package:flutter/foundation.dart';
import 'package:otraku/models/media_entry.dart';

class EntryList {
  final String name;
  final String status;
  final bool isCustomList;
  final String splitCompletedListFormat;
  final List<MediaEntry> entries;

  EntryList({
    @required this.name,
    @required this.status,
    @required this.isCustomList,
    @required this.splitCompletedListFormat,
    @required this.entries,
  });
}
