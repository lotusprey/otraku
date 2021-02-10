import 'package:flutter/foundation.dart';
import 'package:otraku/enums/activity_type.dart';
import 'package:otraku/enums/browsable.dart';
import 'package:otraku/helpers/fn_helper.dart';

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
  final Browsable mediaType;
  final String text;
  final String createdAt;
  final int replyCount;
  final int likeCount;
  final bool isLiked;

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
    @required this.mediaType,
    @required this.text,
    @required this.createdAt,
    @required this.replyCount,
    @required this.likeCount,
    @required this.isLiked,
  });

  factory ActivityModel(final Map<String, dynamic> map) {
    switch (map['type']) {
      case 'TEXT':
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
          mediaType: null,
          text: map['text'],
          createdAt: FnHelper.millisecondsToTimeString(map['createdAt']),
          replyCount: map['replyCount'],
          likeCount: map['likeCount'],
          isLiked: map['isLiked'],
        );
      case 'ANIME_LIST':
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
          mediaType: Browsable.anime,
          text: null,
          createdAt: FnHelper.millisecondsToTimeString(map['createdAt']),
          replyCount: map['replyCount'],
          likeCount: map['likeCount'],
          isLiked: map['isLiked'],
        );
      case 'MANGA_LIST':
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
          mediaType: Browsable.manga,
          text: null,
          createdAt: FnHelper.millisecondsToTimeString(map['createdAt']),
          replyCount: map['replyCount'],
          likeCount: map['likeCount'],
          isLiked: map['isLiked'],
        );
      case 'MESSAGE':
        return ActivityModel._(
          id: map['id'],
          type: ActivityType.MESSAGE,
          agentId: map['messenger']['id'],
          agentName: map['messenger']['name'],
          agentImage: map['messenger']['avatar']['large'],
          recieverId: map['reciever']['id'],
          recieverName: map['reciever']['name'],
          recieverImage: map['reciever']['avatar']['large'],
          mediaId: null,
          mediaTitle: null,
          mediaImage: null,
          mediaType: null,
          text: map['message'],
          createdAt: FnHelper.millisecondsToTimeString(map['createdAt']),
          replyCount: map['replyCount'],
          likeCount: map['likeCount'],
          isLiked: map['isLiked'],
        );
      default:
        return ActivityModel._(
          id: null,
          type: null,
          agentId: null,
          agentName: '',
          agentImage: '',
          recieverId: null,
          recieverName: '',
          recieverImage: '',
          mediaId: null,
          mediaTitle: '',
          mediaImage: '',
          mediaType: null,
          text: '',
          createdAt: null,
          replyCount: null,
          likeCount: null,
          isLiked: null,
        );
    }
  }
}
