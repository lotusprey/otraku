import 'package:otraku/enums/browsable_enum.dart';
import 'package:otraku/controllers/network_service.dart';

class PageItem {
  static Future<bool> toggleFavourite(int id, Browsable browsable) async {
    String idName = const {
      Browsable.anime: 'anime',
      Browsable.manga: 'manga',
      Browsable.characters: 'character',
      Browsable.staff: 'staff',
      Browsable.studios: 'studio',
    }[browsable];

    String pageName = const {
      Browsable.anime: 'anime',
      Browsable.manga: 'manga',
      Browsable.characters: 'characters',
      Browsable.staff: 'staff',
      Browsable.studios: 'studios',
    }[browsable];

    final query = '''
      mutation(\$id: Int) {
        ToggleFavourite(${idName}Id: \$id) {
          $pageName(page: 1, perPage: 1) {
            pageInfo {
              currentPage
            }
          }
        }
      }
    ''';

    final result = await NetworkService.request(
      query,
      {'id': id},
      popOnError: false,
    );

    return result != null;
  }
}
