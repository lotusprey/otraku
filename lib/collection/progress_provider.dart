import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/collection/collection_models.dart';
import 'package:otraku/media/media_constants.dart';
import 'package:otraku/utils/api.dart';
import 'package:otraku/utils/graphql.dart';
import 'package:otraku/utils/options.dart';

final progressProvider = ChangeNotifierProvider.autoDispose(
  (ref) => ProgressNotifier(Options().id!),
);

class ProgressNotifier extends ChangeNotifier {
  ProgressNotifier(this.userId) {
    _fetch();
  }

  final int userId;
  var _state = const AsyncValue<ProgressState>.loading();
  var _hasNextPage = true;
  var _nextPage = 1;

  AsyncValue<ProgressState> get state => _state;

  Future<void> _fetch() async {
    while (_hasNextPage) {
      final value = _state.valueOrNull ?? ProgressState();

      _state = await AsyncValue.guard(() async {
        final data = await Api.get(GqlQuery.progressMedia, {
          'userId': userId,
          'page': _nextPage,
        });

        for (final m in data['Page']['mediaList']) {
          final e = Entry(m);
          final bool isAnime = m['media']['type'] == 'ANIME';
          final status = MediaStatus.values.byName(
            m['media']['status'] ?? 'NOT_YET_RELEASED',
          );

          if (isAnime) {
            if (status == MediaStatus.RELEASING) {
              value.releasingAnime.add(e);
            } else {
              value.otherAnime.add(e);
            }
          } else {
            if (status == MediaStatus.RELEASING) {
              value.releasingManga.add(e);
            } else {
              value.otherManga.add(e);
            }
          }
        }

        if (data['Page']['pageInfo']['hasNextPage'] ?? false) {
          _nextPage++;
        } else {
          _hasNextPage = false;
        }

        return value;
      });
      notifyListeners();
    }
  }

  void remove(int mediaId) {
    final value = _state.valueOrNull;
    if (value == null) return;

    for (final list in value.lists) {
      for (int i = 0; i < list.length; i++) {
        if (list[i].mediaId == mediaId) {
          list.removeAt(i);
          notifyListeners();
          return;
        }
      }
    }
  }

  void add(Entry entry, bool isAnime) {
    if (entry.entryStatus != EntryStatus.CURRENT) return;

    final value = _state.valueOrNull;
    if (value == null) return;

    final status =
        MediaStatus.values.byName(entry.status ?? 'NOT_YET_RELEASED');

    if (isAnime) {
      if (status == MediaStatus.RELEASING) {
        value.releasingAnime.add(entry);
      } else {
        value.otherAnime.add(entry);
      }
    } else {
      if (status == MediaStatus.RELEASING) {
        value.releasingManga.add(entry);
      } else {
        value.otherManga.add(entry);
      }
    }
    notifyListeners();
  }

  void update(Entry entry) {
    if (entry.entryStatus != EntryStatus.CURRENT) {
      remove(entry.mediaId);
      return;
    }

    final value = _state.valueOrNull;
    if (value == null) return;

    for (final list in value.lists) {
      for (int i = 0; i < list.length; i++) {
        if (list[i].mediaId == entry.mediaId) {
          list[i] = entry;
          notifyListeners();
          return;
        }
      }
    }
  }

  void incrementProgress(int mediaId, int progress) {
    final value = _state.valueOrNull;
    if (value == null) return;

    for (final list in value.lists) {
      for (int i = 0; i < list.length; i++) {
        if (list[i].mediaId == mediaId) {
          list[i].progress = progress;
          notifyListeners();
          return;
        }
      }
    }
  }
}

class ProgressState {
  final lists = List.generate(4, (_) => <Entry>[], growable: false);
  List<Entry> get releasingAnime => lists[0];
  List<Entry> get otherAnime => lists[1];
  List<Entry> get releasingManga => lists[2];
  List<Entry> get otherManga => lists[3];
}
