import 'package:otraku/controllers/network_service.dart';
import 'package:otraku/enums/enum_helper.dart';
import 'package:otraku/enums/media_list_status_enum.dart';
import 'package:otraku/models/date_time_mapping.dart';
import 'package:otraku/models/page_data/edit_entry.dart';
import 'package:otraku/models/tuple.dart';

class Entry {
  static const _entryQuery = r'''
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
    }
  ''';

  static Future<EditEntry> fetchUserData(int id) async {
    final data = await NetworkService.request(_entryQuery, {'id': id});

    if (data == null) return null;

    final body = data['Media'];

    if (body['mediaListEntry'] == null) {
      return EditEntry(
        type: body['type'],
        mediaId: id,
        progressMax: body['episodes'] ?? body['chapters'],
        progressVolumesMax: body['voumes'],
      );
    }

    final List<Tuple<String, bool>> customLists = [];
    if (body['mediaListEntry']['customLists'] != null) {
      for (final key in body['mediaListEntry']['customLists'].keys) {
        customLists.add(Tuple(key, body['mediaListEntry']['customLists'][key]));
      }
    }

    return EditEntry(
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
    );
  }
}
