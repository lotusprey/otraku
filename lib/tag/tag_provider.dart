import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/tag/tag_models.dart';
import 'package:otraku/utils/api.dart';

final tagsProvider = FutureProvider(
  (ref) async {
    const query = '''
        query Filters {
          GenreCollection
          MediaTagCollection {id name description category isGeneralSpoiler}
        }
      ''';

    final data = await Api.get(query);
    return TagGroup(data);
  },
);
