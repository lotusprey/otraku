import 'package:get/get.dart';
import 'package:otraku/controllers/home_controller.dart';
import 'package:otraku/models/notification_model.dart';
import 'package:otraku/models/page_model.dart';
import 'package:otraku/utils/client.dart';
import 'package:otraku/utils/graphql.dart';
import 'package:otraku/utils/overscroll_controller.dart';

class NotificationsController extends OverscrollController {
  static const _filters = const [
    null,
    const [
      'ACTIVITY_MESSAGE',
      'ACTIVITY_REPLY',
      'ACTIVITY_REPLY_SUBSCRIBED',
      'ACTIVITY_MENTION',
      'ACTIVITY_LIKE',
      'ACTIVITY_REPLY_LIKE',
    ],
    const [
      'THREAD_COMMENT_REPLY',
      'THREAD_COMMENT_MENTION',
      'THREAD_SUBSCRIBED',
      'THREAD_LIKE',
      'THREAD_COMMENT_LIKE',
    ],
    const ['AIRING', 'RELATED_MEDIA_ADDITION'],
    const ['FOLLOWING'],
  ];

  int _unreadCount = 0;
  int _filter = 0;
  final _entries = PageModel<NotificationModel>();

  @override
  bool get hasNextPage => _entries.hasNextPage;
  int get unreadCount => _unreadCount;
  int get filter => _filter;
  set filter(int val) {
    if (val < 0 || val > _filters.length) return;
    _filter = val;
    _fetch();
    scrollUpTo(0);
  }

  List<NotificationModel> get entries => _entries.items;

  Future<void> _fetch() async {
    final data = await Client.request(
      GqlQuery.notifications,
      {
        'withCount': true,
        'resetCount': true,
        if (_filter != 0) 'filter': _filters[_filter],
      },
    );
    if (data == null) return;

    _unreadCount = _filter == 0 ? data['Viewer']['unreadNotificationCount'] : 0;

    final nl = <NotificationModel>[];
    for (final n in data['Page']['notifications'])
      try {
        nl.add(NotificationModel(n));
      } catch (_) {}

    _entries.replace(nl, data['Page']['pageInfo']['hasNextPage']);
    Get.find<HomeController>().nullifyUnread();
    update();
  }

  @override
  Future<void> fetchPage() async {
    Map<String, dynamic>? data = await Client.request(
      GqlQuery.notifications,
      {
        'page': _entries.nextPage,
        if (_filter != 0) 'filter': _filters[_filter],
      },
    );
    if (data == null) return;

    _unreadCount = data['Viewer']['unreadNotificationCount'];
    data = data['Page'];

    final nl = <NotificationModel>[];
    for (final n in data!['notifications']) nl.add(NotificationModel(n));

    _entries.append(nl, data['pageInfo']['hasNextPage']);
    update();
  }

  @override
  void onInit() {
    super.onInit();
    _fetch();
  }
}
