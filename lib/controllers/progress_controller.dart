import 'package:get/get.dart';
import 'package:otraku/constants/media_status.dart';
import 'package:otraku/models/progress_entry_model.dart';
import 'package:otraku/utils/client.dart';
import 'package:otraku/utils/graphql.dart';
import 'package:otraku/utils/settings.dart';

class ProgressController extends GetxController {
  final releasingAnime = <ProgressEntryModel>[];
  final releasingManga = <ProgressEntryModel>[];
  final otherAnime = <ProgressEntryModel>[];
  final otherManga = <ProgressEntryModel>[];

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

      final data = await Client.request(GqlQuery.currentMedia, {
        'userId': Settings().id,
        'page': 1,
      });
      if (data == null) return;

      for (final m in data['Page']['mediaList']) {
        final model = ProgressEntryModel(m);
        final bool isAnime = m['media']['type'] == 'ANIME';
        final status = MediaStatus.values.byName(m['media']['status']);

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
        return;
      }
    for (int i = 0; i < otherAnime.length; i++)
      if (otherAnime[i].mediaId == mediaId) {
        otherAnime.removeAt(i);
        return;
      }
    for (int i = 0; i < releasingManga.length; i++)
      if (releasingManga[i].mediaId == mediaId) {
        releasingManga.removeAt(i);
        return;
      }
    for (int i = 0; i < otherManga.length; i++)
      if (otherManga[i].mediaId == mediaId) {
        otherManga.removeAt(i);
        return;
      }
  }

  @override
  void onInit() {
    super.onInit();
    fetch();
  }
}
