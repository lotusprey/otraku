import 'package:otraku/providers/collection_provider.dart';

class AnimeCollection extends CollectionProvider {
  AnimeCollection()
      : super(
          isAnime: true,
          typeUCase: 'ANIME',
          typeLCase: 'anime',
          mediaParts: 'episodes',
        );
}
