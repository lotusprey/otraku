import 'package:flutter/foundation.dart';
import 'package:otraku/models/entry_user_data.dart';

class MediaEntry {
  final int mediaId;
  final String title;
  final String cover;
  final String format;
  final String progressMaxString;
  EntryUserData _userData;

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

  EntryUserData get userData {
    return _userData;
  }

  set userData(EntryUserData data) {
    if (data != null) {
      _userData = data;
    }
  }
}
