class StudioItem {
  const StudioItem._({required this.id, required this.name});

  factory StudioItem(Map<String, dynamic> map) =>
      StudioItem._(id: map['id'], name: map['name']);

  final int id;
  final String name;
}
