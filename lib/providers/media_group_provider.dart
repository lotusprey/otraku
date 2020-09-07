abstract class MediaGroupProvider {
  String get search;

  set search(String value);

  bool get isLoading;

  void clear();

  Future<void> fetchMedia();
}
