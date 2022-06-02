import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/utils/api.dart';
import 'package:otraku/utils/convert.dart';
import 'package:otraku/utils/graphql.dart';
import 'package:otraku/utils/pagination.dart';
import 'package:otraku/utils/settings.dart';

/// Toggles an activity like and returns [true] if successful.
Future<bool> toggleActivityLike(Activity activity) async {
  try {
    await Api.get(GqlMutation.toggleLike, {
      'id': activity.id,
      'type': 'ACTIVITY',
    });
    return true;
  } catch (_) {
    return false;
  }
}

/// Toggles an activity subscription and returns [true] if successful.
Future<bool> toggleActivitySubscription(Activity activity) async {
  try {
    await Api.get(GqlMutation.toggleActivitySubscription, {
      'id': activity.id,
      'subscribe': activity.isSubscribed,
    });
    return true;
  } catch (_) {
    return false;
  }
}

/// Toggles a reply like and returns [true] if successful.
Future<bool> toggleReplyLike(ActivityReply reply) async {
  try {
    await Api.get(GqlMutation.toggleLike, {
      'id': reply.id,
      'type': 'ACTIVITY_REPLY',
    });
    return true;
  } catch (_) {
    return false;
  }
}

final activityProvider = StateNotifierProvider.autoDispose
    .family<ActivityNotifier, AsyncValue<ActivityState>, int>(
  (ref, userId) => ActivityNotifier(userId, Settings().id!),
);

class ActivityNotifier extends StateNotifier<AsyncValue<ActivityState>> {
  ActivityNotifier(this.userId, this.viewerId)
      : super(const AsyncValue.loading()) {
    fetch();
  }

  final int userId;
  final int viewerId;

  Future<void> fetch() async {
    state = await AsyncValue.guard(() async {
      final replies = state.value?.replies ?? Pagination();

      final data = await Api.get(GqlQuery.activity, {
        'id': userId,
        'page': replies.next,
        if (replies.next == 1) 'withActivity': true,
      });

      final items = <ActivityReply>[];
      for (final r in data['Page']['activityReplies']) {
        final item = ActivityReply.maybe(r);
        if (item != null) items.add(item);
      }

      final activity =
          state.value?.activity ?? Activity.maybe(data['Activity'], viewerId);
      if (activity == null) throw StateError('Could not parse activity');

      return ActivityState(
        activity,
        replies.append(
          items,
          data['Page']['pageInfo']['hasNextPage'] ?? false,
        ),
      );
    });
  }
}

class ActivityState {
  ActivityState(this.activity, this.replies);

  final Activity activity;
  final Pagination<ActivityReply> replies;
}

class ActivityReply {
  ActivityReply._({
    required this.id,
    required this.user,
    required this.text,
    required this.createdAt,
    this.likeCount = 0,
    this.isLiked = false,
  });

  static ActivityReply? maybe(Map<String, dynamic> map) {
    if (map['id'] == null || map['user']?['id'] == null) return null;

    return ActivityReply._(
      id: map['id'],
      likeCount: map['likeCount'] ?? 0,
      isLiked: map['isLiked'] ?? false,
      user: ActivityUser(map['user']),
      text: map['text'] ?? '',
      createdAt: Convert.millisToStr(map['createdAt']),
    );
  }

  final int id;
  final ActivityUser user;
  final String text;
  final String createdAt;
  int likeCount;
  bool isLiked;
}

class Activity {
  Activity._({
    required this.id,
    required this.type,
    required this.agent,
    required this.createdAt,
    required this.siteUrl,
    required this.isDeletable,
    required this.isPinned,
    this.media,
    this.reciever,
    this.text = '',
    this.likeCount = 0,
    this.replyCount = 0,
    this.isPrivate = false,
    this.isLiked = false,
    this.isSubscribed = false,
  });

  static Activity? maybe(Map<String, dynamic> map, int viewerId) {
    switch (map['type']) {
      case 'TEXT':
        if (map['user'] == null) return null;

        return Activity._(
          id: map['id'],
          type: ActivityType.TEXT,
          agent: ActivityUser(map['user']),
          siteUrl: map['siteUrl'],
          text: map['text'] ?? '',
          createdAt: Convert.millisToStr(map['createdAt']),
          isPinned: map['isPinned'] ?? false,
          isDeletable: map['user']['id'] == viewerId,
          replyCount: map['replyCount'] ?? 0,
          likeCount: map['likeCount'] ?? 0,
          isLiked: map['isLiked'] ?? false,
          isSubscribed: map['isSubscribed'] ?? false,
        );
      case 'ANIME_LIST':
      case 'MANGA_LIST':
        if (map['user'] == null || map['media'] == null) return null;

        final type = map['type'] == 'ANIME_LIST'
            ? ActivityType.ANIME_LIST
            : ActivityType.MANGA_LIST;
        final progress =
            map['progress'] != null ? '${map['progress']} of ' : '';
        final status = (map['status'] as String)[0].toUpperCase() +
            (map['status'] as String).substring(1);

        return Activity._(
          id: map['id'],
          type: type,
          agent: ActivityUser(map['user']),
          media: ActivityMedia(map),
          siteUrl: map['siteUrl'],
          text: '$status $progress',
          createdAt: Convert.millisToStr(map['createdAt']),
          isPinned: map['isPinned'] ?? false,
          isDeletable: map['user']['id'] == viewerId,
          replyCount: map['replyCount'] ?? 0,
          likeCount: map['likeCount'] ?? 0,
          isLiked: map['isLiked'] ?? false,
          isSubscribed: map['isSubscribed'] ?? false,
        );
      case 'MESSAGE':
        if (map['messenger'] == null || map['recipient'] == null) return null;

        return Activity._(
          id: map['id'],
          type: ActivityType.MESSAGE,
          agent: ActivityUser(map['messenger']),
          reciever: ActivityUser(map['recipient']),
          siteUrl: map['siteUrl'],
          text: map['message'] ?? '',
          createdAt: Convert.millisToStr(map['createdAt']),
          isPinned: false,
          isDeletable: map['messenger']['id'] == viewerId ||
              map['recipient']['id'] == viewerId,
          isPrivate: map['isPrivate'] ?? false,
          replyCount: map['replyCount'] ?? 0,
          likeCount: map['likeCount'] ?? 0,
          isLiked: map['isLiked'] ?? false,
          isSubscribed: map['isSubscribed'] ?? false,
        );
      default:
        return null;
    }
  }

  final int id;
  final ActivityType type;
  final ActivityUser agent;
  final ActivityUser? reciever;
  final ActivityMedia? media;
  final String? siteUrl;
  final String text;
  final bool isDeletable;
  final bool isPrivate;
  final bool isPinned;
  final String createdAt;
  int likeCount;
  int replyCount;
  bool isLiked;
  bool isSubscribed;
}

class ActivityUser {
  const ActivityUser._({
    required this.id,
    required this.name,
    required this.imageUrl,
  });

  factory ActivityUser(Map<String, dynamic> map) => ActivityUser._(
        id: map['id'],
        name: map['name'],
        imageUrl: map['avatar']['large'],
      );

  final int id;
  final String name;
  final String imageUrl;
}

class ActivityMedia {
  const ActivityMedia._({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.isAnime,
    required this.format,
  });

  factory ActivityMedia(Map<String, dynamic> map) => ActivityMedia._(
        id: map['media']['id'],
        title: map['media']['title']['userPreferred'],
        imageUrl: map['media']['coverImage'][Settings().imageQuality],
        format: Convert.clarifyEnum(map['media']['format']),
        isAnime: map['type'] == 'ANIME_LIST',
      );

  final int id;
  final String title;
  final String imageUrl;
  final bool isAnime;
  final String? format;
}

enum ActivityType {
  TEXT,
  ANIME_LIST,
  MANGA_LIST,
  MESSAGE;

  String get text {
    switch (this) {
      case ActivityType.TEXT:
        return 'Statuses';
      case ActivityType.ANIME_LIST:
        return 'Anime Progress';
      case ActivityType.MANGA_LIST:
        return 'Manga Progress';
      case ActivityType.MESSAGE:
        return 'Messages';
    }
  }
}
