import 'package:otraku/constants/activity_type.dart';
import 'package:otraku/models/activity_model.dart';
import 'package:otraku/models/page_model.dart';
import 'package:otraku/utils/client.dart';
import 'package:otraku/utils/graphql.dart';
import 'package:otraku/utils/settings.dart';
import 'package:otraku/utils/scrolling_controller.dart';

class FeedController extends ScrollingController {
  static const ID_ACTIVITIES = 0;

  FeedController(this.id);

  final int? id;
  final _activities = PageModel<ActivityModel>();
  final _idNotIn = <int>[];
  late final List<ActivityType> _typeIn;
  bool _isLoading = false;

  List<ActivityModel> get activities => _activities.items;
  List<ActivityType> get typeIn => [..._typeIn];
  set typeIn(List<ActivityType> vals) {
    _typeIn.clear();
    _typeIn.addAll(vals);
    Settings().feedActivityFilters = _typeIn.map((e) => e.index).toList();
    fetchPage(clean: true);
  }

  bool get onFollowing => Settings().feedOnFollowing;
  set onFollowing(bool v) {
    Settings().feedOnFollowing = v;
    fetchPage(clean: true);
  }

  bool get isLoading => _isLoading;

  @override
  Future<void> fetchPage({bool clean = false}) async {
    if (!clean && !_activities.hasNextPage) return;
    _isLoading = true;

    if (clean) {
      scrollUpTo(0);
      _idNotIn.clear();
      _activities.clear();
      update([ID_ACTIVITIES]);
    }

    final data = await Client.request(
      GqlQuery.activities,
      {
        if (id != null) ...{
          'userId': id,
        } else ...{
          'isFollowing': Settings().feedOnFollowing,
          'hasRepliesOrTypeText': Settings().feedOnFollowing ? null : true,
        },
        'page': clean ? 1 : _activities.nextPage,
        'typeIn': _typeIn.map((t) => t.name).toList(),
        'idNotInt': _idNotIn,
      },
    );
    if (data == null) return;

    final al = <ActivityModel>[];
    for (final a in data['Page']['activities'])
      try {
        al.add(ActivityModel(a));
        _idNotIn.add(al.last.id);
      } catch (_) {}

    _activities.append(al, data['Page']['pageInfo']['hasNextPage']);
    _isLoading = false;
    update([ID_ACTIVITIES]);
  }

  ActivityModel? getActivity(int activityId) {
    for (final a in _activities.items) if (a.id == activityId) return a;
    return null;
  }

  void updateActivity(ActivityModel newActivity) {
    for (int i = 0; i < _activities.items.length; i++)
      if (_activities.items[i].id == newActivity.id) {
        _activities.items[i] = newActivity;
        update([ID_ACTIVITIES]);
        break;
      }
  }

  Future<void> deleteActivity(int activityId) async {
    final data =
        await Client.request(GqlMutation.deleteActivity, {'id': activityId});
    if (data == null) return;

    for (int i = 0; i < _activities.items.length; i++)
      if (_activities.items[i].id == activityId) {
        _activities.items.removeAt(i);
        update([ID_ACTIVITIES]);
        break;
      }
  }

  @override
  void onInit() {
    super.onInit();

    _typeIn = id != null
        ? ActivityType.values.toList()
        : Settings()
            .feedActivityFilters
            .map((e) => ActivityType.values.elementAt(e))
            .toList();

    fetchPage();
  }
}
