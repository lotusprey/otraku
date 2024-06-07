import 'package:otraku/feature/discover/discover_models.dart';

class TileItem {
  const TileItem({
    required this.id,
    required this.type,
    required this.title,
    required this.imageUrl,
  });

  final int id;
  final DiscoverType type;
  final String title;
  final String imageUrl;
}
