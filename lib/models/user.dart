import 'package:flutter/foundation.dart';

class User {
  final int id;
  final String name;
  final String description;
  final String avatar;
  final String banner;
  final bool isMe;

  User({
    @required this.id,
    @required this.name,
    @required this.description,
    @required this.avatar,
    @required this.banner,
    this.isMe = false,
  });
}
