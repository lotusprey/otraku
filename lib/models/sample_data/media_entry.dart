import 'package:flutter/foundation.dart';
import 'package:otraku/models/page_data/entry_data.dart';

class MediaEntry {
  final int mediaId;
  final String title;
  final String cover;
  final String format;
  final String progressMaxString;
  EntryData _userData;

  MediaEntry({
    @required this.mediaId,
    @required this.title,
    @required this.cover,
    @required this.format,
    @required this.progressMaxString,
    @required entryUserData,
  }) {
    _userData = entryUserData;
  }

  EntryData get userData {
    return _userData;
  }

  set userData(EntryData data) {
    if (data != null) {
      _userData = data;
    }
  }
}
