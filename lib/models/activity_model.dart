import 'package:otraku/enums/activity_type.dart';
import 'package:otraku/enums/browsable.dart';
import 'package:otraku/utils/convert.dart';
import 'package:otraku/models/reply_model.dart';
import 'package:otraku/models/page_model.dart';

class ActivityModel {
  final int id;
  final ActivityType type;
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
  final Browsable? mediaType;
  final String text;
  final String createdAt;
  final int replyCount;
  final PageModel<ReplyModel> replies;
  late int _likeCount;
  late bool _isLiked;
  late bool _isSubscribed;

  ActivityModel._({
    required this.id,
    required this.type,
    required this.agentId,
    required this.agentName,
    required this.agentImage,
    required this.createdAt,
    required this.replies,
    this.recieverId,
    this.recieverName,
    this.recieverImage,
    this.mediaId,
    this.mediaTitle,
    this.mediaImage,
    this.mediaFormat,
    this.mediaType,
    this.text = '',
    this.replyCount = 0,
    int? likes,
    bool? liked,
    bool? subscribed,
  }) {
    _likeCount = likes ?? 0;
    _isLiked = liked ?? false;
    _isSubscribed = subscribed ?? false;
  }

  factory ActivityModel(Map<String, dynamic> map) {
    switch (map['type']) {
      case 'TEXT':
        if (map['user'] == null) return ActivityModel.empty();

        return ActivityModel._(
          id: map['id'],
          type: ActivityType.TEXT,
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
          text: map['text'],
          createdAt: Convert.millisecondsToTimeString(map['createdAt']),
          replyCount: map['replyCount'],
          replies: PageModel<ReplyModel>([], true, 1),
          likes: map['likeCount'],
          liked: map['isLiked'],
          subscribed: map['isSubscribed'],
        );
      case 'ANIME_LIST':
        if (map['user'] == null || map['media'] == null)
          return ActivityModel.empty();
        final progress =
            map['progress'] != null ? '${map['progress']} of ' : '';
        final status = (map['status'] as String)[0].toUpperCase() +
            (map['status'] as String).substring(1);

        return ActivityModel._(
          id: map['id'],
          type: ActivityType.ANIME_LIST,
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
          mediaType: Browsable.anime,
          text: '$status $progress',
          createdAt: Convert.millisecondsToTimeString(map['createdAt']),
          replyCount: map['replyCount'],
          replies: PageModel<ReplyModel>([], true, 1),
          likes: map['likeCount'],
          liked: map['isLiked'],
          subscribed: map['isSubscribed'],
        );
      case 'MANGA_LIST':
        if (map['user'] == null || map['media'] == null)
          return ActivityModel.empty();
        final progress =
            map['progress'] != null ? '${map['progress']} of ' : '';
        final status = (map['status'] as String)[0].toUpperCase() +
            (map['status'] as String).substring(1);

        return ActivityModel._(
          id: map['id'],
          type: ActivityType.MANGA_LIST,
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
          mediaType: Browsable.manga,
          text: '$status $progress',
          createdAt: Convert.millisecondsToTimeString(map['createdAt']),
          replyCount: map['replyCount'],
          replies: PageModel<ReplyModel>([], true, 1),
          likes: map['likeCount'],
          liked: map['isLiked'],
          subscribed: map['isSubscribed'],
        );
      case 'MESSAGE':
        if (map['messenger'] == null || map['recipient'] == null)
          return ActivityModel.empty();

        return ActivityModel._(
          id: map['id'],
          type: ActivityType.MESSAGE,
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
          text: map['message'],
          createdAt: Convert.millisecondsToTimeString(map['createdAt']),
          replyCount: map['replyCount'],
          replies: PageModel<ReplyModel>([], true, 1),
          likes: map['likeCount'],
          liked: map['isLiked'],
          subscribed: map['isSubscribed'],
        );
      default:
        return ActivityModel.empty();
    }
  }

  factory ActivityModel.empty() => ActivityModel._(
        id: 0,
        type: ActivityType.TEXT,
        agentId: null,
        agentImage: null,
        agentName: null,
        createdAt: '',
        replies: PageModel<ReplyModel>([], true, 1),
      );

  bool get valid => agentId != null;

  int? get likeCount => _likeCount;
  bool? get isLiked => _isLiked;
  bool? get isSubscribed => _isSubscribed;

  void appendReplies(final Map<String, dynamic> map) {
    if (map['activityReplies'] != null) {
      final rl = <ReplyModel>[];
      for (final r in map['activityReplies']) rl.add(ReplyModel(r));
      replies.append(rl, map['pageInfo']['hasNextPage']);
    }
  }

  void toggleLike(final Map<String, dynamic> map) {
    _likeCount = map['likeCount'];
    _isLiked = map['isLiked'];
  }

  void toggleSubscription(final Map<String, dynamic> map) =>
      _isSubscribed = map['isSubscribed'];
}
