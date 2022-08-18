import 'package:otraku/constants/discover_type.dart';

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
  final DiscoverType type;
  final String? subtitle;
}
