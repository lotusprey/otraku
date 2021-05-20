import 'package:get/get.dart';
import 'package:otraku/utils/client.dart';
import 'package:otraku/models/activity_model.dart';
import 'package:otraku/models/reply_model.dart';
import 'package:otraku/utils/scroll_x_controller.dart';

class Activity extends ScrollxController {
  static const _activityQuery = r'''
    query Activity($id: Int, $withActivity: Boolean = false, $page: Int = 1) {
      Activity(id: $id) @include(if: $withActivity) {
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
  Activity(this._id, [this._model, this._callback]);

  ActivityModel? _model;
  final Function(ActivityModel)? _callback;
  final _isLoading = true.obs;

  ActivityModel? get model => _model;
  bool get isLoading => _isLoading();

  @override
  bool get hasNextPage => _model!.replies.hasNextPage;

  Future<void> fetch() async {
    if (_model != null && _model!.replies.items.isNotEmpty) return;
    _isLoading.value = true;

    final data = await Client.request(
      _activityQuery,
      {'id': _id, 'withActivity': true},
    );
    if (data == null) return;

    _model = ActivityModel(data['Activity']);
    _model!.appendReplies(data['Page']);
    _isLoading.value = false;
    update();
  }

  @override
  Future<void> fetchPage() async {
    final data = await Client.request(
      _activityQuery,
      {'id': _id, 'page': _model!.replies.nextPage},
    );
    if (data == null) return;

    _model!.appendReplies(data['Page']);
    update();
  }

  static Future<bool> toggleSubscription(ActivityModel activityModel) async {
    print(activityModel.isSubscribed);
    final data = await Client.request(
      _toggleSubscriptionMutation,
      {'id': activityModel.id, 'subscribe': activityModel.isSubscribed},
      popOnErr: false,
    );
    print(data);
    return data != null;
  }

  static Future<bool> toggleLike(ActivityModel activityModel) async {
    final data = await Client.request(
      _toggleLikeMutation,
      {'id': activityModel.id, 'type': 'ACTIVITY'},
      popOnErr: false,
    );
    return data != null;
  }

  static Future<bool> toggleReplyLike(ReplyModel reply) async {
    final data = await Client.request(
      _toggleLikeMutation,
      {'id': reply.id, 'type': 'ACTIVITY_REPLY'},
      popOnErr: false,
    );
    return data != null;
  }

  @override
  void onInit() {
    super.onInit();
    fetch();
  }

  @override
  void onClose() {
    if (_callback != null && _model != null) _callback!(_model!);
    super.onClose();
  }
}
