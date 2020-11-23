import 'package:get/get.dart';
import 'package:otraku/enums/browsable_enum.dart';
import 'package:otraku/models/page_data/media_data_old.dart';
import 'package:otraku/controllers/network_service.dart';
import 'package:otraku/models/page_data/media_main.dart';

class Media extends GetxController {
  static const _mediaQuery = r'''
    query Media($id: Int) {
      Media(id: $id) {
        type
        title {userPreferred english romaji native}
        synonyms
        coverImage {extraLarge}
        bannerImage
        isFavourite
        favourites
        popularity
        nextAiringEpisode {episode timeUntilAiring}
        mediaListEntry {status}
        description
        format
        status(version: 2)
        episodes
        duration
        chapters
        volumes
        season
        seasonYear
        averageScore
        meanScore
        startDate {year month day}
        endDate {year month day}
        genres
        studios {edges {isMain node {name}}}
        source
        hashtag
        countryOfOrigin
      }
    }
  ''';

  final _main = Rx<MediaMain>();

  MediaMain get main => _main();

  Future<void> fetchMain(int id) async {
    final result = await NetworkService.request(_mediaQuery, {'id': id});

    if (result == null) return null;
    final data = result['Media'];

    _main(MediaMain(
      id: id,
      browsable: data['type'] == 'ANIME' ? Browsable.anime : Browsable.manga,
      isFavourite: data['isFavourite'],
      favourites: data['favourites'],
      preferredTitle: data['title']['userPreferred'],
      romajiTitle: data['title']['romaji'],
      endDate: data['title']['english'],
      nativeTitle: data['title']['native'],
      synonyms: data['synonyms'],
    ));
  }

  static Future<MediaDataOld> fetchItemData(int id) async {
    final data = await NetworkService.request(_mediaQuery, {'id': id});

    if (data == null) return null;

    return MediaDataOld(id, data['Media']);
  }
}
