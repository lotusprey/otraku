import 'package:otraku/extension/date_time_extension.dart';
import 'package:otraku/extension/string_extension.dart';
import 'package:otraku/feature/viewer/persistence_model.dart';
import 'package:otraku/util/paged.dart';
import 'package:otraku/util/markdown.dart';

const homeFeedId = -1;

class ExpandedActivity {
  ExpandedActivity(this.activity, this.replies);

  final Activity activity;
  final Paged<ActivityReply> replies;
}

class ActivityReply {
  ActivityReply._({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.authorAvatarUrl,
    required this.text,
    required this.createdAt,
    this.likeCount = 0,
    this.isLiked = false,
  });

  static ActivityReply? maybe(Map<String, dynamic> map) {
    if (map['id'] == null || map['user']?['id'] == null) return null;

    return ActivityReply._(
      id: map['id'],
      authorId: map['user']['id'],
      authorName: map['user']['name'],
      authorAvatarUrl: map['user']['avatar']['large'],
      text: parseMarkdown(map['text'] ?? ''),
      createdAt:
          DateTimeExtension.formattedDateTimeFromSeconds(map['createdAt']),
      likeCount: map['likeCount'] ?? 0,
      isLiked: map['isLiked'] ?? false,
    );
  }

  final int id;
  final int authorId;
  final String authorName;
  final String authorAvatarUrl;
  final String text;
  final String createdAt;
  int likeCount;
  bool isLiked;
}

sealed class Activity {
  Activity({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.authorAvatarUrl,
    required this.createdAt,
    required this.text,
    required this.siteUrl,
    required this.isOwned,
    required this.replyCount,
    required this.likeCount,
    required this.isLiked,
    required this.isSubscribed,
    required this.isPinned,
  });

  static Activity? maybe(
    Map<String, dynamic> map,
    int? viewerId,
    ImageQuality imageQuality,
  ) {
    try {
      switch (map['type']) {
        case 'TEXT':
          if (map['user'] == null) return null;

          return StatusActivity(
            id: map['id'],
            authorId: map['user']['id'],
            authorName: map['user']['name'],
            authorAvatarUrl: map['user']['avatar']['large'],
            siteUrl: map['siteUrl'],
            text: parseMarkdown(map['text'] ?? ''),
            createdAt: DateTimeExtension.formattedDateTimeFromSeconds(
              map['createdAt'],
            ),
            isOwned: map['user']['id'] == viewerId,
            replyCount: map['replyCount'] ?? 0,
            likeCount: map['likeCount'] ?? 0,
            isLiked: map['isLiked'] ?? false,
            isSubscribed: map['isSubscribed'] ?? false,
            isPinned: map['isPinned'] ?? false,
          );
        case 'MESSAGE':
          if (map['messenger'] == null || map['recipient'] == null) return null;

          return MessageActivity(
            id: map['id'],
            authorId: map['messenger']['id'],
            authorName: map['messenger']['name'],
            authorAvatarUrl: map['messenger']['avatar']['large'],
            recipientId: map['recipient']['id'],
            recipientName: map['recipient']['name'],
            recipientAvatarUrl: map['recipient']['avatar']['large'],
            siteUrl: map['siteUrl'],
            text: parseMarkdown(map['message'] ?? ''),
            createdAt: DateTimeExtension.formattedDateTimeFromSeconds(
              map['createdAt'],
            ),
            isOwned: map['messenger']['id'] == viewerId ||
                map['recipient']['id'] == viewerId,
            isPrivate: map['isPrivate'] ?? false,
            replyCount: map['replyCount'] ?? 0,
            likeCount: map['likeCount'] ?? 0,
            isLiked: map['isLiked'] ?? false,
            isSubscribed: map['isSubscribed'] ?? false,
            isPinned: false,
          );
        case 'ANIME_LIST':
        case 'MANGA_LIST':
          if (map['user'] == null || map['media'] == null) return null;

          final progress =
              map['progress'] != null ? '${map['progress']} of ' : '';
          final status = (map['status'] as String)[0].toUpperCase() +
              (map['status'] as String).substring(1);

          return MediaActivity(
            id: map['id'],
            authorId: map['user']['id'],
            authorName: map['user']['name'],
            authorAvatarUrl: map['user']['avatar']['large'],
            mediaId: map['media']['id'],
            title: map['media']['title']['userPreferred'],
            coverUrl: map['media']['coverImage'][imageQuality.value],
            format:
                StringExtension.tryNoScreamingSnakeCase(map['media']['format']),
            isAnime: map['type'] == 'ANIME_LIST',
            siteUrl: map['siteUrl'],
            text: '$status $progress',
            createdAt: DateTimeExtension.formattedDateTimeFromSeconds(
              map['createdAt'],
            ),
            isOwned: map['user']['id'] == viewerId,
            replyCount: map['replyCount'] ?? 0,
            likeCount: map['likeCount'] ?? 0,
            isLiked: map['isLiked'] ?? false,
            isSubscribed: map['isSubscribed'] ?? false,
            isPinned: map['isPinned'] ?? false,
          );
        default:
          return null;
      }
    } catch (_) {
      return null;
    }
  }

  final int id;
  final int authorId;
  final String authorName;
  final String authorAvatarUrl;
  final String createdAt;
  final String text;
  final String siteUrl;
  final bool isOwned;
  int replyCount;
  int likeCount;
  bool isLiked;
  bool isSubscribed;
  bool isPinned;
}

class StatusActivity extends Activity {
  StatusActivity({
    required super.id,
    required super.authorId,
    required super.authorName,
    required super.authorAvatarUrl,
    required super.createdAt,
    required super.text,
    required super.siteUrl,
    required super.isOwned,
    required super.replyCount,
    required super.likeCount,
    required super.isLiked,
    required super.isSubscribed,
    required super.isPinned,
  });
}

class MessageActivity extends Activity {
  MessageActivity({
    required super.id,
    required super.authorId,
    required super.authorName,
    required super.authorAvatarUrl,
    required super.createdAt,
    required super.text,
    required super.siteUrl,
    required super.isOwned,
    required super.replyCount,
    required super.likeCount,
    required super.isLiked,
    required super.isSubscribed,
    required super.isPinned,
    required this.recipientId,
    required this.recipientName,
    required this.recipientAvatarUrl,
    required this.isPrivate,
  });

  final int recipientId;
  final String recipientName;
  final String recipientAvatarUrl;
  final bool isPrivate;
}

class MediaActivity extends Activity {
  MediaActivity({
    required super.id,
    required super.authorId,
    required super.authorName,
    required super.authorAvatarUrl,
    required super.createdAt,
    required super.text,
    required super.siteUrl,
    required super.isOwned,
    required super.replyCount,
    required super.likeCount,
    required super.isLiked,
    required super.isSubscribed,
    required super.isPinned,
    required this.mediaId,
    required this.title,
    required this.coverUrl,
    required this.isAnime,
    required this.format,
  });

  final int mediaId;
  final String title;
  final String coverUrl;
  final bool isAnime;
  final String? format;
}
