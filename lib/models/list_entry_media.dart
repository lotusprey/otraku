import 'package:flutter/foundation.dart';
import 'package:otraku/models/list_entry_user_data.dart';

class ListEntryMedia {
  final int id;
  final String title;
  final String cover;
  final String format;
  final String progressMaxString;
  ListEntryUserData userData;

  ListEntryMedia({
    @required this.id,
    @required this.title,
    @required this.cover,
    @required this.format,
    @required this.progressMaxString,
    @required this.userData,
  });
}
