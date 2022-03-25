import 'package:otraku/constants/explorable.dart';

class RelationModel {
  RelationModel({
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
