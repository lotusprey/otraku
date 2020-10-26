import 'package:flutter/foundation.dart';
import 'package:otraku/enums/media_list_status_enum.dart';
import 'package:otraku/models/sample_data/media_entry.dart';

class EntryList {
  final String name;
  final MediaListStatus status;
  final bool isCustomList;
  final String splitCompletedListFormat;
  final List<MediaEntry> entries;

  EntryList({
    @required this.name,
    @required this.isCustomList,
    @required this.entries,
    this.status,
    this.splitCompletedListFormat,
  });
}
