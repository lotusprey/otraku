import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:otraku/enums/activity_type.dart';
import 'package:otraku/models/activity_model.dart';
import 'package:otraku/models/page_model.dart';
import 'package:otraku/utils/client.dart';
import 'package:otraku/utils/config.dart';
import 'package:otraku/utils/overscroll_controller.dart';

class FeedController extends OverscrollController {
  static const _activitiesQuery = r'''
    query Activities($userId: Int, $page: Int = 1, $idNotIn: [Int], $isFollowing: Boolean, $hasRepliesOrTypeText: Boolean, $typeIn: [ActivityType]) {
      Page(page: $page) {
        pageInfo {hasNextPage}
        activities(userId: $userId, id_not_in: $idNotIn, isFollowing: $isFollowing, hasRepliesOrTypeText: $hasRepliesOrTypeText, type_in: $typeIn, sort: ID_DESC) {
          ... on TextActivity {
            id
            type
            replyCount
            likeCount
            isLiked
            isSubscribed
            createdAt
            siteUrl
            user {id name avatar {large}}
            text(asHtml: true)
          }
          ... on ListActivity {
            id
            type
            replyCount
            likeCount
            isLiked
            isSubscribed
            createdAt
            siteUrl
            user {id name avatar {large}}
            media {id type title{userPreferred} coverImage{large} format}
            progress
            status
          }
          ... on MessageActivity {
            id
            type
            replyCount
            likeCount
            isLiked
            isSubscribed
            isPrivate
            createdAt
            siteUrl
            recipient {id name avatar {large}}
            messenger {id name avatar {large}}
            message(asHtml: true)
          }
        }
      }
    }
  ''';

  static const _deleteMutation = r'''
    mutation DeleteActivity($id: Int) {DeleteActivity(id: $id) {deleted}}
  ''';

  static const HOME_FEED_TAG = 'Feed';

  final int? id;
  FeedController(this.id);

  final _activities = PageModel<ActivityModel>().obs;
  final _idNotIn = <int>[];
  late final List<ActivityType> _typeIn;
  bool _onFollowing = Config.storage.read(Config.FOLLOWING_FEED) ?? true;
  bool _isLoading = false;

  List<ActivityModel> get activities => _activities().items;
  List<ActivityType> get typeIn => [..._typeIn];
  set typeIn(List<ActivityType> vals) {
    _typeIn.clear();
    _typeIn.addAll(vals);
    fetchPage(clean: true);
  }

  bool get onFollowing => _onFollowing;
  set onFollowing(bool val) {
    _onFollowing = val;
    Config.storage.write(Config.FOLLOWING_FEED, val);
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
      _activitiesQuery,
      {
        if (id != null) ...{
          'userId': id,
        } else ...{
          'isFollowing': _onFollowing,
          'hasRepliesOrTypeText': _onFollowing ? null : true,
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
    final data = await Client.request(_deleteMutation, {'id': activityId});
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
