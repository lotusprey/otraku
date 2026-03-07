import 'package:otraku/extension/enum_extension.dart';

sealed class ActivitiesFilter {
  const ActivitiesFilter();

  ActivitiesFilter copy();

  Map<String, dynamic> toGraphQlVariables();
}

class HomeActivitiesFilter extends ActivitiesFilter {
  const HomeActivitiesFilter(
    this.viewerId,
    this.onFollowing,
    this.withViewerActivities,
    this.typeIn,
  );

  factory HomeActivitiesFilter.empty() =>
      const HomeActivitiesFilter(null, false, false, [.animeStatus, .mangaStatus, .status]);

  factory HomeActivitiesFilter.fromPersistenceMap(Map<dynamic, dynamic> map, int? viewerId) {
    final List<int> typeIn =
        map['activityTypeIn'] ??
        [ActivityType.status.index, ActivityType.animeStatus.index, ActivityType.mangaStatus.index];

    return HomeActivitiesFilter(
      viewerId,
      map['onFollowing'] ?? false,
      map['withViewerActivities'] ?? false,
      typeIn.map((index) => ActivityType.values.getOrFirst(index)).toList(),
    );
  }

  final int? viewerId;
  final bool onFollowing;
  final bool withViewerActivities;
  final List<ActivityType> typeIn;

  @override
  HomeActivitiesFilter copy() =>
      HomeActivitiesFilter(viewerId, onFollowing, withViewerActivities, [...typeIn]);

  HomeActivitiesFilter copyWith({
    bool? onFollowing,
    bool? withViewerActivities,
    List<ActivityType>? typeIn,
  }) => HomeActivitiesFilter(
    viewerId,
    onFollowing ?? this.onFollowing,
    withViewerActivities ?? this.withViewerActivities,
    typeIn ?? this.typeIn,
  );

  @override
  Map<String, dynamic> toGraphQlVariables() => {
    'isFollowing': onFollowing,
    if (!onFollowing) 'hasRepliesOrText': true,
    if (!withViewerActivities && viewerId != null) 'userIdNot': viewerId,
    'typeIn': typeIn.map((t) => t.value).toList(),
  };

  Map<String, dynamic> toPersistenceMap() => {
    'onFollowing': onFollowing,
    'withViewerActivities': withViewerActivities,
    'activityTypeIn': typeIn.map((a) => a.index).toList(),
  };
}

class UserActivitiesFilter extends ActivitiesFilter {
  const UserActivitiesFilter(this.userId, this.typeIn);

  final int userId;
  final List<ActivityType> typeIn;

  @override
  UserActivitiesFilter copy() => UserActivitiesFilter(userId, [...typeIn]);

  UserActivitiesFilter copyWithTypeIn(List<ActivityType> typeIn) =>
      UserActivitiesFilter(userId, typeIn);

  @override
  Map<String, dynamic> toGraphQlVariables() => {
    'userId': userId,
    'typeIn': typeIn.map((t) => t.value).toList(),
  };
}

//made it so it now supports userId values
class MediaActivitiesFilter extends ActivitiesFilter {
  const MediaActivitiesFilter(this.mediaId, this.onlyFollowing, {this.userId});

  final int mediaId;
  final bool onlyFollowing;
  final int? userId;

  @override
  MediaActivitiesFilter copy() => MediaActivitiesFilter(mediaId, onlyFollowing, userId: userId);

  MediaActivitiesFilter copyWith({bool? onlyFollowing, int? userId, bool clearUserId = false}) =>
      MediaActivitiesFilter(
        mediaId,
        onlyFollowing ?? this.onlyFollowing,
        userId: clearUserId ? null : (userId ?? this.userId),
      );

  @override
  Map<String, dynamic> toGraphQlVariables() => {
    'mediaId': mediaId,
    if (onlyFollowing) 'isFollowing': true,
    if (userId != null) 'userId': userId,
  };

  Map<String, dynamic> toPersistenceMap() => {'onlyFollowing': onlyFollowing, 'userId': userId};

  static MediaActivitiesFilter fromPersistence(int mediaId, Map<dynamic, dynamic> map) =>
      MediaActivitiesFilter(mediaId, map['onlyFollowing'] ?? false, userId: map['userId']);
}

enum ActivityType {
  status('Statuses', 'TEXT'),
  animeStatus('Anime Progress', 'ANIME_LIST'),
  mangaStatus('Manga Progress', 'MANGA_LIST'),
  message('Messages', 'MESSAGE');

  const ActivityType(this.label, this.value);

  final String label;
  final String value;
}
