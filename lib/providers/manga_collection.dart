import 'package:otraku/providers/collection_provider.dart';

class MangaCollection extends CollectionProvider {
  MangaCollection()
      : super(
          isAnime: false,
          typeUCase: 'MANGA',
          typeLCase: 'manga',
          mediaParts: 'chapters',
        );
}
