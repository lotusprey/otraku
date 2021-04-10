class StudioModel {
  final int id;
  final String name;
  final bool isAnimationStudio;
  final int favourites;
  bool isFavourite;

  StudioModel._({
    required this.id,
    required this.name,
    this.favourites = 0,
    this.isFavourite = false,
    this.isAnimationStudio = true,
  });

  factory StudioModel(Map<String, dynamic> map) => StudioModel._(
        id: map['id'],
        name: map['name'],
        favourites: map['favourites'] ?? 0,
        isFavourite: map['isFavourite'] ?? false,
        isAnimationStudio: map['isAnimationStudio'] ?? true,
      );
}
