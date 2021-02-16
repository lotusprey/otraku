import 'package:otraku/helpers/graph_ql.dart';
import 'package:otraku/models/anilist/activity_model.dart';

class Activity {
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
      text {asHtml: true}
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

  ActivityModel _activity;

  ActivityModel get model => _activity;

  // TODO: Finish activity fetching
  Future<void> fetch(final int id, final ActivityModel activityModel) async {
    final data = await GraphQL.request(
      _activityQuery,
      {'id': id, 'withActivity': activityModel == null},
    );
    if (data == null) return;

    if (activityModel == null)
      _activity = ActivityModel(data['Activity']);
    else
      _activity = activityModel..appendReplies(data['Activity']);
  }

  static Future<void> toggleLike(ActivityModel activity) async {
    final data = await GraphQL.request(
      _toggleLikeMutation,
      {'id': activity.id},
      popOnErr: false,
    );
    if (data == null) return;
    activity.toggleLike(data['ToggleLikeV2']);
  }

  static Future<void> toggleSubscription(ActivityModel activity) async {
    final data = await GraphQL.request(
      _toggleSubscriptionMutation,
      {'id': activity.id, 'subscribe': !activity.isSubscribed},
      popOnErr: false,
    );
    if (data == null) return;
    activity.toggleSubscription(data['ToggleActivitySubscription']);
  }
}
