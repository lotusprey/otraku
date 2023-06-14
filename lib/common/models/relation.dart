import 'package:otraku/modules/discover/discover_models.dart';

class Relation {
  Relation({
    required this.id,
    required this.type,
    required this.title,
    required this.imageUrl,
    this.subtitle,
  });

  final int id;
  final DiscoverType type;
  final String title;
  final String imageUrl;
  final String? subtitle;
}
