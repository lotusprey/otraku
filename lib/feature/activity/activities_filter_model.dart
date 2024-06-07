sealed class ActivitiesFilter {
  const ActivitiesFilter(this.typeIn);

  final List<ActivityType> typeIn;

  ActivitiesFilter copyWith({List<ActivityType>? typeIn});
}

class UserActivitiesFilter extends ActivitiesFilter {
  const UserActivitiesFilter(super.typeIn, this.userId);

  final int userId;

  @override
  ActivitiesFilter copyWith({List<ActivityType>? typeIn}) =>
      UserActivitiesFilter(typeIn ?? this.typeIn, userId);
}

class HomeActivitiesFilter extends ActivitiesFilter {
  const HomeActivitiesFilter(
    super.typeIn,
    this.onFollowing,
    this.withViewerActivities,
  );

  final bool onFollowing;
  final bool withViewerActivities;

  @override
  ActivitiesFilter copyWith({
    List<ActivityType>? typeIn,
    bool? onFollowing,
    bool? withViewerActivities,
  }) =>
      HomeActivitiesFilter(
        typeIn ?? this.typeIn,
        onFollowing ?? this.onFollowing,
        withViewerActivities ?? this.withViewerActivities,
      );
}

enum ActivityType {
  TEXT('Statuses'),
  ANIME_LIST('Anime Progress'),
  MANGA_LIST('Manga Progress'),
  MESSAGE('Messages');

  const ActivityType(this.text);

  final String text;
}
