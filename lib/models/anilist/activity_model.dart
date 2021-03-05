import 'package:flutter/foundation.dart';
import 'package:otraku/enums/activity_type.dart';
import 'package:otraku/enums/browsable.dart';
import 'package:otraku/helpers/fn_helper.dart';
import 'package:otraku/models/anilist/reply_model.dart';
import 'package:otraku/models/loadable_list.dart';

class ActivityModel {
  final int id;
  final ActivityType type;
  final int agentId;
  final String agentName;
  final String agentImage;
  final int recieverId;
  final String recieverName;
  final String recieverImage;
  final int mediaId;
  final String mediaTitle;
  final String mediaImage;
  final String mediaFormat;
  final Browsable mediaType;
  final String text;
  final String createdAt;
  final int replyCount;
  final LoadableList<ReplyModel> replies;
  int _likeCount;
  bool _isLiked;
  bool _isSubscribed;

  ActivityModel._({
    @required this.id,
    @required this.type,
    @required this.agentId,
    @required this.agentName,
    @required this.agentImage,
    @required this.recieverId,
    @required this.recieverName,
    @required this.recieverImage,
    @required this.mediaId,
    @required this.mediaTitle,
    @required this.mediaImage,
    @required this.mediaFormat,
    @required this.mediaType,
    @required this.text,
    @required this.createdAt,
    @required this.replyCount,
    @required this.replies,
    @required int likes,
    @required bool liked,
    @required bool subscribed,
  }) {
    _likeCount = likes;
    _isLiked = liked;
    _isSubscribed = subscribed;
  }

  factory ActivityModel(Map<String, dynamic> map) {
    switch (map['type']) {
      case 'TEXT':
        if (map['user'] == null) return null;

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
          createdAt: FnHelper.millisecondsToTimeString(map['createdAt']),
          replyCount: map['replyCount'] ?? 0,
          replies: LoadableList<ReplyModel>([], true, 1),
          likes: map['likeCount'] ?? 0,
          liked: map['isLiked'] ?? false,
          subscribed: map['isSubscribed'] ?? false,
        );
      case 'ANIME_LIST':
        if (map['user'] == null || map['media'] == null) return null;
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
          mediaFormat: FnHelper.clarifyEnum(map['media']['format']),
          mediaType: Browsable.anime,
          text: '$status $progress',
          createdAt: FnHelper.millisecondsToTimeString(map['createdAt']),
          replyCount: map['replyCount'] ?? 0,
          replies: LoadableList<ReplyModel>([], true, 1),
          likes: map['likeCount'] ?? 0,
          liked: map['isLiked'] ?? false,
          subscribed: map['isSubscribed'] ?? false,
        );
      case 'MANGA_LIST':
        if (map['user'] == null || map['media'] == null) return null;
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
          mediaFormat: FnHelper.clarifyEnum(map['media']['format']),
          mediaType: Browsable.manga,
          text: '$status $progress',
          createdAt: FnHelper.millisecondsToTimeString(map['createdAt']),
          replyCount: map['replyCount'] ?? 0,
          replies: LoadableList<ReplyModel>([], true, 1),
          likes: map['likeCount'] ?? 0,
          liked: map['isLiked'] ?? false,
          subscribed: map['isSubscribed'] ?? false,
        );
      case 'MESSAGE':
        if (map['messenger'] == null || map['recipient'] == null) return null;

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
          createdAt: FnHelper.millisecondsToTimeString(map['createdAt']),
          replyCount: map['replyCount'] ?? 0,
          replies: LoadableList<ReplyModel>([], true, 1),
          likes: map['likeCount'] ?? 0,
          liked: map['isLiked'] ?? false,
          subscribed: map['isSubscribed'] ?? false,
        );
      default:
        return null;
    }
  }

  int get likeCount => _likeCount;
  bool get isLiked => _isLiked;
  bool get isSubscribed => _isSubscribed;

  void appendReplies(final Map<String, dynamic> map) {
    if (map['activityReplies'] != null) {
      final List<ReplyModel> rl = [];
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
