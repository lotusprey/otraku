/// A lot of models have commonly accessed elements
/// that can be unified and used in agnostic views.
abstract class TileModelable {
  int get tileId;
  String get tileTitle;
  String? get tileSubtitle;
  String get tileImageUrl;
}
