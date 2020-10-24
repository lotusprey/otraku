import 'package:flutter/foundation.dart';
import 'package:otraku/models/user_settings.dart';

class User {
  final int id;
  final String name;
  final String description;
  final String avatar;
  final String banner;
  final UserSettings settings;
  final bool isMe;

  User({
    @required this.id,
    @required this.name,
    @required this.description,
    @required this.avatar,
    @required this.banner,
    @required this.settings,
    this.isMe = false,
  });
}
