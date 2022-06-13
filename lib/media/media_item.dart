import 'package:otraku/utils/settings.dart';

class MediaItem {
  MediaItem._({required this.id, required this.name, required this.imageUrl});

  factory MediaItem(Map<String, dynamic> map) => MediaItem._(
        id: map['id'],
        name: map['title']['userPreferred'],
        imageUrl: map['coverImage'][Settings().imageQuality],
      );

  final int id;
  final String name;
  final String imageUrl;
}
