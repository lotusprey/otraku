class TagModel {
  final String name;
  final String desciption;
  final bool isGeneralSpoiler;

  TagModel._({
    required this.name,
    required this.desciption,
    required this.isGeneralSpoiler,
  });

  factory TagModel(Map<String, dynamic> map) => TagModel._(
        name: map['name'],
        desciption: map['description'] ?? 'No description',
        isGeneralSpoiler: map['isGeneralSpoiler'] ?? false,
      );
}
