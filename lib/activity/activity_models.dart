import 'package:otraku/utils/convert.dart';
import 'package:otraku/common/paged.dart';
import 'package:otraku/utils/options.dart';

class ActivityState {
  ActivityState(this.activity, this.replies);

  final Activity activity;
  final Paged<ActivityReply> replies;
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
    required this.isOwned,
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
    try {
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
            isOwned: map['user']['id'] == viewerId,
            replyCount: map['replyCount'] ?? 0,
            likeCount: map['likeCount'] ?? 0,
            isLiked: map['isLiked'] ?? false,
            isSubscribed: map['isSubscribed'] ?? false,
            isPinned: map['isPinned'] ?? false,
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
            isOwned: map['user']['id'] == viewerId,
            replyCount: map['replyCount'] ?? 0,
            likeCount: map['likeCount'] ?? 0,
            isLiked: map['isLiked'] ?? false,
            isSubscribed: map['isSubscribed'] ?? false,
            isPinned: map['isPinned'] ?? false,
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
            isOwned: map['messenger']['id'] == viewerId ||
                map['recipient']['id'] == viewerId,
            isPrivate: map['isPrivate'] ?? false,
            replyCount: map['replyCount'] ?? 0,
            likeCount: map['likeCount'] ?? 0,
            isLiked: map['isLiked'] ?? false,
            isSubscribed: map['isSubscribed'] ?? false,
            isPinned: false,
          );
        default:
          return null;
      }
    } catch (_) {
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
  final bool isOwned;
  final bool isPrivate;
  final String createdAt;
  int likeCount;
  int replyCount;
  bool isLiked;
  bool isSubscribed;
  bool isPinned;
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
        imageUrl: map['media']['coverImage'][Options().imageQuality.value],
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
  TEXT('Statuses'),
  ANIME_LIST('Anime Progress'),
  MANGA_LIST('Manga Progress'),
  MESSAGE('Messages');

  const ActivityType(this.text);

  final String text;
}

class ActivityFilter {
  const ActivityFilter(this.typeIn, this.onFollowing);

  final List<ActivityType> typeIn;

  /// Not `null` only for the main feed. Switches between following/global.
  final bool? onFollowing;
}
