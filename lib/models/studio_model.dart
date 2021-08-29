class StudioModel {
  final int id;
  final String name;
  final bool isAnimationStudio;
  final int favourites;
  bool isFavourite;

  StudioModel._({
    required this.id,
    required this.name,
    required this.favourites,
    required this.isFavourite,
    required this.isAnimationStudio,
  });

  factory StudioModel(Map<String, dynamic> map) => StudioModel._(
        id: map['id'],
        name: map['name'],
        favourites: map['favourites'] ?? 0,
        isFavourite: map['isFavourite'] ?? false,
        isAnimationStudio: map['isAnimationStudio'] ?? true,
      );
}
