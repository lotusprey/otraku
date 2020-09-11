import 'package:flutter/foundation.dart';
import 'package:otraku/models/media_entry.dart';

class EntryList {
  final String name;
  final String status;
  final bool isSplitCompletedList;
  final List<MediaEntry> entries;

  EntryList({
    @required this.name,
    @required this.status,
    @required this.isSplitCompletedList,
    @required this.entries,
  });
}
