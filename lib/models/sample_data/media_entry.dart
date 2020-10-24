import 'package:flutter/foundation.dart';
import 'package:otraku/models/page_data/entry_data.dart';

class MediaEntry {
  final int mediaId;
  final String title;
  final String cover;
  final int nextEpisode;
  final String timeUntilAiring;
  EntryData userData;

  MediaEntry({
    @required this.mediaId,
    @required this.title,
    @required this.cover,
    @required this.nextEpisode,
    @required this.timeUntilAiring,
    @required this.userData,
  });
}
