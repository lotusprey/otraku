import 'package:get/get.dart';
import 'package:otraku/helpers/graph_ql.dart';
import 'package:otraku/models/anilist/activity_model.dart';

class Activity extends GetxController {
  static const _activityQuery = r'''
    query Activity($id: Int, $withActivity: Boolean = false) {
      Activity(id: $id) {
        ... on TextActivity {
          ...text @include(if: $withActivity)
          replies {...reply}
        }
        ... on ListActivity {
          ...list @include(if: $withActivity)
          replies {...reply}
        }
        ... on MessageActivity {
          ...message @include(if: $withActivity)
          replies {...reply}
        }
      }
    }
    fragment text on TextActivity {
      id
      type
      replyCount
      likeCount
      isLiked
      createdAt
      user {id name avatar {large}}
      text(asHtml: true)
    }
    fragment list on ListActivity {
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
    fragment message on MessageActivity {
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
    fragment reply on ActivityReply {
      id
      likeCount
      isLiked
      createdAt
      text(asHtml: true)
      user {id name avatar {large}}
    }
  ''';

  static const _toggleLikeMutation = r'''
    mutation ToggleLikeActivity($id: Int) {
      ToggleLikeV2(id: $id, type: ACTIVITY) {
        ... on ListActivity {likeCount isLiked}
        ... on TextActivity {likeCount isLiked}
        ... on MessageActivity {likeCount isLiked}
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

  ActivityModel get model => _model;

  Future<void> fetch() async {
    final data = await GraphQL.request(
      _activityQuery,
      {'id': _id, 'withActivity': _model == null},
    );
    if (data == null) return;

    if (_model == null)
      _model = ActivityModel(data['Activity']);
    else
      _model.appendReplies(data['Activity']);
    update();
  }

  static Future<void> toggleLike(ActivityModel activityModel) async {
    final data = await GraphQL.request(
      _toggleLikeMutation,
      {'id': activityModel.id},
      popOnErr: false,
    );
    if (data == null) return;
    activityModel.toggleLike(data['ToggleLikeV2']);
  }

  static Future<void> toggleSubscription(ActivityModel activityModel) async {
    final data = await GraphQL.request(
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
