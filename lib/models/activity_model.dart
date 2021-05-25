import 'package:otraku/enums/activity_type.dart';
import 'package:otraku/enums/explorable.dart';
import 'package:otraku/utils/client.dart';
import 'package:otraku/utils/convert.dart';
import 'package:otraku/models/reply_model.dart';
import 'package:otraku/models/page_model.dart';

class ActivityModel {
  final int id;
  final ActivityType type;
  final bool deletable;
  final int? agentId;
  final String? agentName;
  final String? agentImage;
  final int? recieverId;
  final String? recieverName;
  final String? recieverImage;
  final int? mediaId;
  final String? mediaTitle;
  final String? mediaImage;
  final String? mediaFormat;
  final Explorable? mediaType;
  final bool isPrivate;
  final String text;
  final String createdAt;
  final replies = PageModel<ReplyModel>();
  int replyCount;
  int likeCount;
  bool isLiked;
  bool isSubscribed;

  ActivityModel._({
    required this.id,
    required this.type,
    required this.deletable,
    required this.agentId,
    required this.agentName,
    required this.agentImage,
    required this.createdAt,
    this.recieverId,
    this.recieverName,
    this.recieverImage,
    this.mediaId,
    this.mediaTitle,
    this.mediaImage,
    this.mediaFormat,
    this.mediaType,
    this.text = '',
    this.isPrivate = false,
    this.replyCount = 0,
    this.likeCount = 0,
    this.isLiked = false,
    this.isSubscribed = false,
  });

  factory ActivityModel(Map<String, dynamic> map) {
    final myId = Client.viewerId;

    switch (map['type']) {
      case 'TEXT':
        if (map['user'] == null) throw ArgumentError.notNull('user');

        return ActivityModel._(
          id: map['id'],
          type: ActivityType.TEXT,
          deletable: map['user']['id'] == myId,
          agentId: map['user']['id'],
          agentName: map['user']['name'],
          agentImage: map['user']['avatar']['large'],
          recieverId: null,
          recieverName: null,
          recieverImage: null,
          mediaId: null,
          mediaTitle: null,
          mediaImage: null,
          mediaFormat: null,
          mediaType: null,
          text: map['text'] ?? '',
          createdAt: Convert.millisToTimeStr(map['createdAt']),
          replyCount: map['replyCount'] ?? 0,
          likeCount: map['likeCount'] ?? 0,
          isLiked: map['isLiked'] ?? false,
          isSubscribed: map['isSubscribed'] ?? false,
        );
      case 'ANIME_LIST':
        if (map['user'] == null || map['media'] == null)
          throw ArgumentError.notNull('user/media');
        final progress =
            map['progress'] != null ? '${map['progress']} of ' : '';
        final status = (map['status'] as String)[0].toUpperCase() +
            (map['status'] as String).substring(1);

        return ActivityModel._(
          id: map['id'],
          type: ActivityType.ANIME_LIST,
          deletable: map['user']['id'] == myId,
          agentId: map['user']['id'],
          agentName: map['user']['name'],
          agentImage: map['user']['avatar']['large'],
          recieverId: null,
          recieverName: null,
          recieverImage: null,
          mediaId: map['media']['id'],
          mediaTitle: map['media']['title']['userPreferred'],
          mediaImage: map['media']['coverImage']['large'],
          mediaFormat: Convert.clarifyEnum(map['media']['format']),
          mediaType: Explorable.anime,
          text: '$status $progress',
          createdAt: Convert.millisToTimeStr(map['createdAt']),
          replyCount: map['replyCount'] ?? 0,
          likeCount: map['likeCount'] ?? 0,
          isLiked: map['isLiked'] ?? false,
          isSubscribed: map['isSubscribed'] ?? false,
        );
      case 'MANGA_LIST':
        if (map['user'] == null || map['media'] == null)
          throw ArgumentError.notNull('user/media');
        final progress =
            map['progress'] != null ? '${map['progress']} of ' : '';
        final status = (map['status'] as String)[0].toUpperCase() +
            (map['status'] as String).substring(1);

        return ActivityModel._(
          id: map['id'],
          type: ActivityType.MANGA_LIST,
          deletable: map['user']['id'] == myId,
          agentId: map['user']['id'],
          agentName: map['user']['name'],
          agentImage: map['user']['avatar']['large'],
          recieverId: null,
          recieverName: null,
          recieverImage: null,
          mediaId: map['media']['id'],
          mediaTitle: map['media']['title']['userPreferred'],
          mediaImage: map['media']['coverImage']['large'],
          mediaFormat: Convert.clarifyEnum(map['media']['format']),
          mediaType: Explorable.manga,
          text: '$status $progress',
          createdAt: Convert.millisToTimeStr(map['createdAt']),
          replyCount: map['replyCount'] ?? 0,
          likeCount: map['likeCount'] ?? 0,
          isLiked: map['isLiked'] ?? false,
          isSubscribed: map['isSubscribed'] ?? false,
        );
      case 'MESSAGE':
        if (map['messenger'] == null || map['recipient'] == null)
          throw ArgumentError.notNull('messenger/recipient');

        return ActivityModel._(
          id: map['id'],
          type: ActivityType.MESSAGE,
          deletable:
              map['messenger']['id'] == myId || map['recipient']['id'] == myId,
          agentId: map['messenger']['id'],
          agentName: map['messenger']['name'],
          agentImage: map['messenger']['avatar']['large'],
          recieverId: map['recipient']['id'],
          recieverName: map['recipient']['name'],
          recieverImage: map['recipient']['avatar']['large'],
          mediaId: null,
          mediaTitle: null,
          mediaImage: null,
          mediaFormat: null,
          mediaType: null,
          isPrivate: map['isPrivate'] ?? false,
          text: map['message'] ?? '',
          createdAt: Convert.millisToTimeStr(map['createdAt']),
          replyCount: map['replyCount'] ?? 0,
          likeCount: map['likeCount'] ?? 0,
          isLiked: map['isLiked'] ?? false,
          isSubscribed: map['isSubscribed'] ?? false,
        );
      default:
        throw ArgumentError.notNull('type');
    }
  }

  void appendReplies(final Map<String, dynamic> map) {
    if (map['activityReplies'] == null) return;

    final rl = <ReplyModel>[];
    for (final r in map['activityReplies'])
      try {
        rl.add(ReplyModel(r));
      } catch (_) {}

    replies.append(rl, map['pageInfo']['hasNextPage']);

    if (replyCount < replies.items.length) replyCount = replies.items.length;
  }

  void toggleSubscription() => isSubscribed = !isSubscribed;

  void toggleLike() {
    if (isLiked) {
      isLiked = false;
      likeCount--;
    } else {
      isLiked = true;
      likeCount++;
    }
  }

  void updateFrom(ActivityModel model) {
    isSubscribed = model.isSubscribed;
    replyCount = model.replyCount;
    likeCount = model.likeCount;
    isLiked = model.isLiked;
  }
}
