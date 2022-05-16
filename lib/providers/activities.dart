import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/utils/client.dart';
import 'package:otraku/utils/convert.dart';
import 'package:otraku/utils/graphql.dart';
import 'package:otraku/utils/pagination.dart';
import 'package:otraku/utils/settings.dart';

final activityFilterProvider =
    StateProvider.autoDispose.family<List<ActivityType>, int?>(
  (ref, userId) => userId != null
      ? ActivityType.values
      : Settings()
          .feedActivityFilters
          .map((e) => ActivityType.values.elementAt(e))
          .toList(),
);

final activitiesProvider = StateNotifierProvider.autoDispose
    .family<ActivitiesNotifier, AsyncValue<Pagination<Activity>>, int>(
  (ref, userId) => ActivitiesNotifier(
    userId: userId,
    viewerId: Settings().id!,
    typeIn: ref.watch(activityFilterProvider(userId)),
  ),
);

class ActivitiesNotifier
    extends StateNotifier<AsyncValue<Pagination<Activity>>> {
  ActivitiesNotifier({
    required this.userId,
    required this.viewerId,
    required this.typeIn,
  }) : super(const AsyncValue.loading()) {
    fetch();
  }

  final int userId;
  final int viewerId;
  final List<ActivityType> typeIn;

  Future<void> fetch() async {
    state = await AsyncValue.guard(() async {
      final value = state.value ?? Pagination();

      final data = await Client.get(GqlQuery.activities, {
        'userId': userId,
        'page': value.next,
        'typeIn': typeIn.map((t) => t.name).toList(),
      });

      final items = <Activity>[];
      for (final a in data['Page']['activities']) {
        final item = Activity.maybe(a, viewerId);
        if (item != null) items.add(item);
      }

      return value.append(
        items,
        data['Page']['pageInfo']['hasNextPage'] ?? false,
      );
    });
  }

  /// Toggles an activity like and returns [true] if successful.
  Future<bool> toggleLike(int activityId) async {
    try {
      await Client.get(GqlMutation.toggleLike, {
        'id': activityId,
        'type': 'ACTIVITY',
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Toggles an activity subscription and returns [true] if successful.
  Future<bool> toggleSubscription(int activityId, bool subscribe) async {
    try {
      await Client.get(GqlMutation.toggleActivitySubscription, {
        'id': activityId,
        'subscribe': subscribe,
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Deletes an activity.
  Future<void> delete(int activityId) async {
    Client.get(GqlMutation.deleteActivity, {'id': activityId}).then((_) {
      if (!state.hasValue) return;
      final value = state.value!;

      for (int i = 0; i < value.items.length; i++)
        if (value.items[i].id == activityId) {
          state = AsyncData(value.copyWith([...value.items..removeAt(i)]));
          return;
        }
    }).catchError((_) {});
  }
}

class Activity {
  Activity._({
    required this.id,
    required this.type,
    required this.agent,
    required this.createdAt,
    required this.siteUrl,
    required this.isDeletable,
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
