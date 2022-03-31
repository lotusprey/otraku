import 'package:otraku/models/studio_model.dart';
import 'package:otraku/utils/client.dart';
import 'package:otraku/utils/convert.dart';
import 'package:otraku/constants/media_sort.dart';
import 'package:otraku/models/group_page_model.dart';
import 'package:otraku/models/explorable_model.dart';
import 'package:otraku/utils/graphql.dart';
import 'package:otraku/utils/scrolling_controller.dart';

class StudioController extends ScrollingController {
  StudioController(this.id);

  final int id;
  StudioModel? _model;
  final _media = GroupPageModel<ExplorableModel>();
  MediaSort _sort = MediaSort.START_DATE_DESC;
  bool? _onList;

  StudioModel? get model => _model;
  GroupPageModel<ExplorableModel> get media => _media;

  MediaSort get sort => _sort;
  bool? get onList => _onList;

  void filter(MediaSort sortVal, bool? onListVal) {
    if (sortVal == _sort && onListVal == _onList) return;
    _sort = sortVal;
    _onList = onListVal;
    refetch();
  }

  Future<void> _fetch() async {
    final data = await Client.request(
      GqlQuery.studio,
      {'id': id, 'withMain': true, 'sort': _sort.name},
    );
    if (data == null) return;

    _model = StudioModel(data['Studio']);
    _initMedia(data['Studio']['media'], false);
    update();
  }

  Future<void> refetch() async {
    scrollCtrl.scrollUpTo(0);

    final data = await Client.request(
      GqlQuery.studio,
      {'id': id, 'sort': _sort.name, 'onList': _onList},
    );
    if (data == null) return;

    _initMedia(data['Studio']['media'], true);
    update();
  }

  @override
  Future<void> fetchPage() async {
    if (!_media.hasNextPage) return;

    final data = await Client.request(
      GqlQuery.studio,
      {
        'id': id,
        'page': _media.nextPage,
        'sort': _sort.name,
        'onList': _onList,
      },
    );
    if (data == null) return;

    _initMedia(data['Studio']['media'], false);
    update();
  }

  Future<bool> toggleFavourite() async {
    final data =
        await Client.request(GqlMutation.toggleFavourite, {'studio': id});
    if (data != null) _model!.isFavourite = !_model!.isFavourite;
    return _model!.isFavourite;
  }

  void _initMedia(Map<String, dynamic> data, bool clear) {
    if (clear) _media.clear();

    final categories = <String>[];
    final results = <List<ExplorableModel>>[];

    for (final node in data['nodes']) {
      final String category =
          (node['startDate']['year'] ?? Convert.clarifyEnum(node['status']))
              .toString();

      if (categories.isEmpty || categories.last != category) {
        categories.add(category);
        results.add([]);
      }

      results.last.add(ExplorableModel.anime(node));
    }

    _media.append(categories, results, data['pageInfo']['hasNextPage']);
  }

  @override
  void onInit() {
    super.onInit();
    if (_model == null) _fetch();
  }
}
