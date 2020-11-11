import 'package:otraku/enums/enum_helper.dart';
import 'package:otraku/enums/media_list_status_enum.dart';
import 'package:otraku/models/page_data/edit_entry.dart';
import 'package:otraku/models/date_time_mapping.dart';
import 'package:otraku/models/page_data/media.dart';
import 'package:otraku/models/tuple.dart';
import 'package:otraku/controllers/network_service.dart';

class MediaItem {
  static Future<Media> fetchItemData(int id) async {
    const query = r'''
      query Media($id: Int) {
        Media(id: $id) {
          type
          title {
            userPreferred
            english
            romaji
            native
          }
          nextAiringEpisode {airingAt}
          coverImage {extraLarge}
          bannerImage
          isFavourite
          popularity
          favourites
          nextAiringEpisode {episode timeUntilAiring}
          mediaListEntry {status}
          description
          format
          status
          episodes
          duration
          chapters
          volumes
          season
          seasonYear
          source
          hashtag
          countryOfOrigin
          startDate {year month day}
          endDate {year month day}
          averageScore
          meanScore
          studios {
            edges {
              node {name}
              isMain
            }
          }
        }
      }
    ''';

    final data = await NetworkService.request(query, {'id': id});

    if (data == null) return null;

    return Media(id, data['Media']);
  }

  static Future<Tuple<EditEntry, String>> fetchUserData(int id) async {
    final query = r'''
      query ItemUserData($id: Int) {
        Media(id: $id) {
          id
          type
          episodes
          chapters
          volumes
          mediaListEntry {
            id
            status
            progress
            progressVolumes
            score
            repeat
            notes
            startedAt {year month day}
            completedAt {year month day}
            private
            hiddenFromStatusLists
            customLists
          }
        }
        Viewer {mediaListOptions {scoreFormat}}
      }
    ''';

    final data = await NetworkService.request(query, {'id': id});

    if (data == null) return null;

    final body = data['Media'];

    if (body['mediaListEntry'] == null) {
      return Tuple(
        EditEntry(
          type: body['type'],
          mediaId: id,
          progressMax: body['episodes'] ?? body['chapters'],
          progressVolumesMax: body['voumes'],
        ),
        data['Viewer']['mediaListOptions']['scoreFormat'],
      );
    }

    final List<Tuple<String, bool>> customLists = [];
    if (body['mediaListEntry']['customLists'] != null) {
      for (final key in body['mediaListEntry']['customLists'].keys) {
        customLists.add(Tuple(key, body['mediaListEntry']['customLists'][key]));
      }
    }

    return Tuple(
      EditEntry(
        type: body['type'],
        mediaId: id,
        entryId: body['mediaListEntry']['id'],
        status: stringToEnum(
          body['mediaListEntry']['status'],
          MediaListStatus.values,
        ),
        progress: body['mediaListEntry']['progress'] ?? 0,
        progressMax: body['episodes'] ?? body['chapters'],
        progressVolumes: body['mediaListEntry']['volumes'] ?? 0,
        progressVolumesMax: body['voumes'],
        score: body['mediaListEntry']['score'].toDouble(),
        repeat: body['mediaListEntry']['repeat'],
        notes: body['mediaListEntry']['notes'],
        startedAt: mapToDateTime(body['mediaListEntry']['startedAt']),
        completedAt: mapToDateTime(body['mediaListEntry']['completedAt']),
        private: body['mediaListEntry']['private'],
        hiddenFromStatusLists: body['mediaListEntry']['hiddenFromStatusLists'],
        customLists: customLists,
      ),
      data['Viewer']['mediaListOptions']['scoreFormat'],
    );
  }
}
