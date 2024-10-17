import 'package:otraku/extension/enum_extension.dart';

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

  factory HomeActivitiesFilter.empty() => const HomeActivitiesFilter(
        [ActivityType.ANIME_LIST, ActivityType.MANGA_LIST, ActivityType.TEXT],
        false,
        false,
      );

  factory HomeActivitiesFilter.fromMap(Map<String, dynamic> map) =>
      HomeActivitiesFilter(
        map['activityTypeIn']
            .map((index) => ActivityType.values.getOrFirst(index))
            .toList(),
        map['onFollowing'],
        map['withViewerActivities'],
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

  Map<String, dynamic> toMap() => {
        'activityTypeIn': typeIn.map((a) => a.index).toList(),
        'onFollowing': onFollowing,
        'withViewerActivities': withViewerActivities,
      };
}

enum ActivityType {
  TEXT('Statuses'),
  ANIME_LIST('Anime Progress'),
  MANGA_LIST('Manga Progress'),
  MESSAGE('Messages');

  const ActivityType(this.text);

  final String text;
}
