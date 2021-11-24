import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:otraku/constants/activity_type.dart';
import 'package:otraku/models/activity_model.dart';
import 'package:otraku/models/page_model.dart';
import 'package:otraku/utils/client.dart';
import 'package:otraku/utils/graphql.dart';
import 'package:otraku/utils/local_settings.dart';
import 'package:otraku/utils/overscroll_controller.dart';

class FeedController extends OverscrollController {
  static const HOME_FEED_TAG = 'Feed';

  FeedController(this.id);

  final int? id;
  final _activities = PageModel<ActivityModel>().obs;
  final _idNotIn = <int>[];
  late final List<ActivityType> _typeIn;
  bool _isLoading = false;

  List<ActivityModel> get activities => _activities().items;
  List<ActivityType> get typeIn => [..._typeIn];
  set typeIn(List<ActivityType> vals) {
    _typeIn.clear();
    _typeIn.addAll(vals);
    fetchPage(clean: true);
  }

  bool get onFollowing => LocalSettings().lastFeed;
  set onFollowing(bool v) {
    LocalSettings().lastFeed = v;
    fetchPage(clean: true);
  }

  bool get isLoading => _isLoading;

  @override
  bool get hasNextPage => _activities().hasNextPage;

  @override
  Future<void> fetchPage({bool clean = false}) async {
    _isLoading = true;

    if (clean) {
      scrollUpTo(0);
      _idNotIn.clear();
      _activities.update((a) => a!.clear());
    }

    final data = await Client.request(
      GqlQuery.activities,
      {
        if (id != null) ...{
          'userId': id,
        } else ...{
          'isFollowing': LocalSettings().lastFeed,
          'hasRepliesOrTypeText': LocalSettings().lastFeed ? null : true,
        },
        'page': clean ? 1 : _activities().nextPage,
        'typeIn': _typeIn.map((t) => describeEnum(t)).toList(),
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

    _activities.update(
      (a) => a!.append(al, data['Page']['pageInfo']['hasNextPage']),
    );

    _isLoading = false;
  }

  ActivityModel? getActivity(int activityId) {
    for (final a in _activities().items) if (a.id == activityId) return a;
    return null;
  }

  void updateActivity(ActivityModel newActivity) {
    for (int i = 0; i < _activities().items.length; i++)
      if (_activities().items[i].id == newActivity.id) {
        _activities.update((a) => a!.items[i] = newActivity);
        break;
      }
  }

  Future<void> deleteActivity(int activityId) async {
    final data =
        await Client.request(GqlMutation.deleteActivity, {'id': activityId});
    if (data == null) return;

    for (int i = 0; i < _activities().items.length; i++)
      if (_activities().items[i].id == activityId) {
        _activities.update((a) => a!.items.removeAt(i));
        break;
      }
  }

  @override
  void onInit() {
    super.onInit();

    _typeIn = id == null
        ? [ActivityType.TEXT, ActivityType.ANIME_LIST, ActivityType.MANGA_LIST]
        : ActivityType.values.toList();

    fetchPage();
  }
}
