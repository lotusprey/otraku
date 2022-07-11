import 'package:otraku/constants/explorable.dart';

class Relation {
  Relation({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.type,
    this.subtitle,
  });

  final int id;
  final String title;
  final String imageUrl;
  final Explorable type;
  final String? subtitle;
}
