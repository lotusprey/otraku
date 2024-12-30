import 'package:otraku/feature/viewer/persistence_model.dart';

class MediaItem {
  const MediaItem._({
    required this.id,
    required this.name,
    required this.imageUrl,
  });

  factory MediaItem(Map<String, dynamic> map, ImageQuality imageQuality) =>
      MediaItem._(
        id: map['id'],
        name: map['title']['userPreferred'],
        imageUrl: map['coverImage'][imageQuality.value],
      );

  final int id;
  final String name;
  final String imageUrl;
}
