import 'package:flutter/foundation.dart';
import 'package:otraku/models/entry_user_data.dart';

class MediaEntry {
  final int id;
  final String title;
  final String cover;
  final String format;
  final String progressMaxString;
  EntryUserData userData;

  MediaEntry({
    @required this.id,
    @required this.title,
    @required this.cover,
    @required this.format,
    @required this.progressMaxString,
    @required this.userData,
  });
}
