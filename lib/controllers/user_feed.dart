import 'package:get/get.dart';
import 'package:otraku/controllers/user.dart';
import 'package:otraku/models/activity_model.dart';
import 'package:otraku/models/user_model.dart';
import 'package:otraku/utils/client.dart';
import 'package:otraku/utils/scroll_x_controller.dart';

class UserFeed extends ScrollxController {
  static const _activitiesQuery = r'''
    query Activities($id: Int, $page: Int = 1) {
      Page(page: $page) {
        pageInfo {hasNextPage}
        activities(userId: $id, sort: ID_DESC) {
          ... on TextActivity {
            id
            type
            replyCount
            likeCount
            isLiked
            isSubscribed
            createdAt
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
            recipient {id name avatar {large}}
            messenger {id name avatar {large}}
            message(asHtml: true)
          }
        }
      }
    }
  ''';

  final int id;
  UserFeed(this.id);

  late UserModel _model;

  @override
  bool get hasNextPage => _model.activities.hasNextPage;
  List<ActivityModel> get activities => _model.activities.items;

  @override
  Future<void> fetchPage() async {
    final data = await Client.request(_activitiesQuery, {
      'id': id,
      'page': _model.activities.nextPage,
    });
    if (data == null) return;

    final al = <ActivityModel>[];
    for (final a in data['Page']['activities']) {
      try {
        al.add(ActivityModel(a));
      } catch (_) {}
    }
    _model.activities.append(al, data['Page']['pageInfo']['hasNextPage']);
    update();
  }

  @override
  void onInit() {
    super.onInit();
    _model = Get.find<User>(tag: id.toString()).model!;
    if (_model.activities.items.isEmpty) fetchPage();
  }
}
