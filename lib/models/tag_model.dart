class TagModel {
  final String name;
  final String desciption;
  final bool isSpoiler;
  final int? rank;

  TagModel._({
    required this.name,
    required this.rank,
    required this.desciption,
    required this.isSpoiler,
  });

  factory TagModel(Map<String, dynamic> map) => TagModel._(
        name: map['name'],
        rank: map['rank'],
        desciption: map['description'] ?? 'No description',
        isSpoiler: (map['isGeneralSpoiler'] ?? false) ||
            (map['isMediaSpoiler'] ?? false),
      );
}
