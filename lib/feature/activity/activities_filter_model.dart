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

class MediaActivitiesFilter extends ActivitiesFilter {
  const MediaActivitiesFilter(this.socialGroup, this.mediaId, this.viewerId);

  factory MediaActivitiesFilter.empty() => const MediaActivitiesFilter(.global, 0, null);

  final int mediaId;
  final ActivitySocialGroup socialGroup;
  final int? viewerId;

  @override
  MediaActivitiesFilter copy() => MediaActivitiesFilter(socialGroup, mediaId, viewerId);

  MediaActivitiesFilter copyWith({
    ActivitySocialGroup? socialGroup,
    int? mediaId,
    (int?,)? viewerId,
  }) => MediaActivitiesFilter(
    socialGroup ?? this.socialGroup,
    mediaId ?? this.mediaId,
    viewerId != null ? viewerId.$1 : this.viewerId,
  );

  @override
  Map<String, dynamic> toGraphQlVariables() => {
    'mediaId': mediaId,
    ...switch (socialGroup) {
      .global => const {},
      .followed => const {'isFollowing': true},
      .self => viewerId != null ? {'userId': viewerId} : {'isFollowing': true},
    },
  };

  Map<String, dynamic> toPersistenceMap() => {'socialGroup': socialGroup.index};

  static MediaActivitiesFilter fromPersistence(
    Map<dynamic, dynamic> map,
    int mediaId,
    int? viewerId,
  ) => MediaActivitiesFilter(
    ActivitySocialGroup.values.getOrFirst(map['socialGroup']),
    mediaId,
    viewerId,
  );
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

enum ActivitySocialGroup { global, followed, self }
