import 'package:get/get.dart';
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
  // TODO no obs
  final _media = GroupPageModel<ExplorableModel>().obs;
  MediaSort _sort = MediaSort.START_DATE_DESC;
  bool? _onList;

  StudioModel? get model => _model;
  GroupPageModel<ExplorableModel> get media => _media();

  MediaSort get sort => _sort;
  set sort(MediaSort value) {
    _sort = value;
    refetch();
  }

  bool? get onList => _onList;
  set onList(bool? val) {
    _onList = val;
    refetch();
  }

  Future<void> _fetch() async {
    final data = await Client.request(
      GqlQuery.studio,
      {'id': id, 'withMain': true, 'sort': _sort.name},
    );
    if (data == null) return;

    _model = StudioModel(data['Studio']);
    update();

    _initMedia(data['Studio']['media'], false);
  }

  Future<void> refetch() async {
    scrollUpTo(0);

    final data = await Client.request(
      GqlQuery.studio,
      {'id': id, 'sort': _sort.name, 'onList': _onList},
    );
    if (data == null) return;

    _initMedia(data['Studio']['media'], true);
  }

  @override
  Future<void> fetchPage() async {
    if (!_media().hasNextPage) return;

    final data = await Client.request(
      GqlQuery.studio,
      {
        'id': id,
        'page': _media().nextPage,
        'sort': _sort.name,
        'onList': _onList,
      },
    );
    if (data == null) return;

    _initMedia(data['Studio']['media'], false);
  }

  Future<bool> toggleFavourite() async {
    final data =
        await Client.request(GqlMutation.toggleFavourite, {'studio': id});
    if (data != null) _model!.isFavourite = !_model!.isFavourite;
    return _model!.isFavourite;
  }

  void _initMedia(Map<String, dynamic> data, bool clear) {
    if (clear) _media().clear();

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

    _media.update((m) => m!.append(
          categories,
          results,
          data['pageInfo']['hasNextPage'],
        ));
  }

  @override
  void onInit() {
    super.onInit();
    if (_model == null) _fetch();
  }
}
