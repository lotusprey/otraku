import 'package:get/get.dart';
import 'package:otraku/collection/entry.dart';
import 'package:otraku/collection/entry_item.dart';
import 'package:otraku/constants/media_status.dart';
import 'package:otraku/utils/api.dart';
import 'package:otraku/utils/graphql.dart';
import 'package:otraku/utils/settings.dart';

class ProgressController extends GetxController {
  final releasingAnime = <EntryItem>[];
  final releasingManga = <EntryItem>[];
  final otherAnime = <EntryItem>[];
  final otherManga = <EntryItem>[];

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetch() async {
    releasingAnime.clear();
    releasingManga.clear();
    otherAnime.clear();
    otherManga.clear();

    int nextPage = 1;
    while (nextPage > 0) {
      _isLoading = true;
      update();

      final data = await Api.request(GqlQuery.currentMedia, {
        'userId': Settings().id,
        'page': nextPage,
      });
      if (data == null) return;

      for (final m in data['Page']['mediaList']) {
        final model = EntryItem(m);
        final bool isAnime = m['media']['type'] == 'ANIME';
        final status = MediaStatus.values.byName(
          m['media']['status'] ?? 'NOT_YET_RELEASED',
        );

        if (isAnime) {
          if (status == MediaStatus.RELEASING)
            releasingAnime.add(model);
          else
            otherAnime.add(model);
        } else {
          if (status == MediaStatus.RELEASING)
            releasingManga.add(model);
          else
            otherManga.add(model);
        }
      }

      if (data['Page']['pageInfo']['hasNextPage'] ?? false)
        nextPage++;
      else
        nextPage = 0;

      _isLoading = false;
      update();
    }
  }

  void remove(int mediaId) {
    for (int i = 0; i < releasingAnime.length; i++)
      if (releasingAnime[i].mediaId == mediaId) {
        releasingAnime.removeAt(i);
        update();
        return;
      }
    for (int i = 0; i < otherAnime.length; i++)
      if (otherAnime[i].mediaId == mediaId) {
        otherAnime.removeAt(i);
        update();
        return;
      }
    for (int i = 0; i < releasingManga.length; i++)
      if (releasingManga[i].mediaId == mediaId) {
        releasingManga.removeAt(i);
        update();
        return;
      }
    for (int i = 0; i < otherManga.length; i++)
      if (otherManga[i].mediaId == mediaId) {
        otherManga.removeAt(i);
        update();
        return;
      }
  }

  void add(Entry entry, bool isAnime) {
    if (entry.entryStatus != EntryStatus.CURRENT) return;

    final status = MediaStatus.values.byName(
      entry.status ?? 'NOT_YET_RELEASED',
    );
    final item = EntryItem.fromEntry(entry);

    if (isAnime) {
      if (status == MediaStatus.RELEASING)
        releasingAnime.add(item);
      else
        otherAnime.add(item);
    } else {
      if (status == MediaStatus.RELEASING)
        releasingManga.add(item);
      else
        otherManga.add(item);
    }
  }

  void updateEntry(Entry entry, bool isAnime) {
    if (entry.entryStatus != EntryStatus.CURRENT) {
      remove(entry.mediaId);
      return;
    }

    if (isAnime) {
      for (int i = 0; i < releasingAnime.length; i++)
        if (releasingAnime[i].mediaId == entry.mediaId) {
          releasingAnime[i] = EntryItem.fromEntry(entry);
          update();
          return;
        }
      for (int i = 0; i < otherAnime.length; i++)
        if (otherAnime[i].mediaId == entry.mediaId) {
          otherAnime[i] = EntryItem.fromEntry(entry);
          update();
          return;
        }
    } else {
      for (int i = 0; i < releasingManga.length; i++)
        if (releasingManga[i].mediaId == entry.mediaId) {
          releasingManga[i] = EntryItem.fromEntry(entry);
          update();
          return;
        }
      for (int i = 0; i < otherManga.length; i++)
        if (otherManga[i].mediaId == entry.mediaId) {
          otherManga[i] = EntryItem.fromEntry(entry);
          update();
          return;
        }
    }
  }

  void incrementProgress(int mediaId, int progress) {
    for (int i = 0; i < releasingAnime.length; i++)
      if (releasingAnime[i].mediaId == mediaId) {
        releasingAnime[i].progress = progress;
        return;
      }
    for (int i = 0; i < otherAnime.length; i++)
      if (otherAnime[i].mediaId == mediaId) {
        otherAnime[i].progress = progress;
        return;
      }
    for (int i = 0; i < releasingManga.length; i++)
      if (releasingManga[i].mediaId == mediaId) {
        releasingManga[i].progress = progress;
        return;
      }
    for (int i = 0; i < otherManga.length; i++)
      if (otherManga[i].mediaId == mediaId) {
        otherManga[i].progress = progress;
        return;
      }
  }

  @override
  void onInit() {
    super.onInit();
    fetch();
  }
}
