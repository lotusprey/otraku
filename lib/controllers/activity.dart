import 'package:get/get.dart';
import 'package:otraku/utils/client.dart';
import 'package:otraku/models/anilist/activity_model.dart';
import 'package:otraku/models/anilist/reply_model.dart';

class Activity extends GetxController {
  static const _activityQuery = r'''
    query Activity($id: Int, $withActivity: Boolean = false, $page: Int = 1) {
      Activity(id: $id) @include(if: $withActivity) {
        ... on TextActivity {
          id
          type
          replyCount
          likeCount
          isLiked
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
          createdAt
          recipient {id name avatar {large}}
          messenger {id name avatar {large}}
          message(asHtml: true)
        }
      }
      Page(page: $page) {
        pageInfo {hasNextPage}
        activityReplies(activityId: $id) {
          id
          likeCount
          isLiked
          createdAt
          text(asHtml: true)
          user {id name avatar {large}}
        }
      }
    }
  ''';

  static const _toggleLikeMutation = r'''
    mutation ToggleLike($id: Int, $type: LikeableType) {
      ToggleLikeV2(id: $id, type: $type) {
        ... on ListActivity {likeCount isLiked}
        ... on TextActivity {likeCount isLiked}
        ... on MessageActivity {likeCount isLiked}
        ... on ActivityReply {likeCount isLiked}
      }
    }
  ''';

  static const _toggleSubscriptionMutation = r'''
    mutation ToggleSubscription($id: Int, $subscribe: Boolean) {
      ToggleActivitySubscription(activityId: $id, subscribe: $subscribe) {
        ... on ListActivity {isSubscribed}
        ... on TextActivity {isSubscribed}
        ... on MessageActivity {isSubscribed}
      }
    }
  ''';

  final int _id;
  Activity(this._id, [this._model]);

  ActivityModel _model;
  final _isLoading = true.obs;

  ActivityModel get model => _model;
  bool get isLoading => _isLoading();

  Future<void> fetch() async {
    if (_model != null && _model.replies.items.isNotEmpty) return;
    _isLoading.value = true;

    final data = await Client.request(
      _activityQuery,
      {'id': _id, 'withActivity': true},
    );
    if (data == null) return;

    _model = ActivityModel(data['Activity']);
    _model.appendReplies(data['Page']);
    _isLoading.value = false;
    update();
  }

  Future<void> fetchPage() async {
    if (!_model.replies.hasNextPage) return;

    final data = await Client.request(
      _activityQuery,
      {'id': _id, 'page': _model.replies.nextPage},
    );
    if (data == null) return;

    _model.appendReplies(data['Page']);
    update();
  }

  static Future<void> toggleActivityLike(ActivityModel activityModel) async {
    final data = await Client.request(
      _toggleLikeMutation,
      {'id': activityModel.id, 'type': 'ACTIVITY'},
      popOnErr: false,
    );
    if (data == null) return;
    activityModel.toggleLike(data['ToggleLikeV2']);
  }

  static Future<void> toggleReplyLike(ReplyModel reply) async {
    final data = await Client.request(
      _toggleLikeMutation,
      {'id': reply.id, 'type': 'ACTIVITY_REPLY'},
      popOnErr: false,
    );
    if (data == null) return;
    reply.toggleLike(data['ToggleLikeV2']);
  }

  static Future<void> toggleSubscription(ActivityModel activityModel) async {
    final data = await Client.request(
      _toggleSubscriptionMutation,
      {'id': activityModel.id, 'subscribe': !activityModel.isSubscribed},
      popOnErr: false,
    );
    if (data == null) return;
    activityModel.toggleSubscription(data['ToggleActivitySubscription']);
  }

  @override
  void onInit() {
    super.onInit();
    fetch();
  }
}
