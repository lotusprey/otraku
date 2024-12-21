import 'package:otraku/extension/enum_extension.dart';

sealed class ActivitiesFilter {
  const ActivitiesFilter(this.typeIn);

  final List<ActivityType> typeIn;

  ActivitiesFilter copy();

  ActivitiesFilter copyWith({List<ActivityType>? typeIn});
}

class UserActivitiesFilter extends ActivitiesFilter {
  const UserActivitiesFilter(super.typeIn, this.userId);

  final int userId;

  @override
  ActivitiesFilter copy() => UserActivitiesFilter([...typeIn], userId);

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
        [
          ActivityType.animeStatus,
          ActivityType.mangaStatus,
          ActivityType.status
        ],
        false,
        false,
      );

  factory HomeActivitiesFilter.fromPersistenceMap(Map<dynamic, dynamic> map) {
    final List<int> typeIn = map['activityTypeIn'] ??
        List.generate(ActivityType.values.length, (i) => i, growable: false);

    return HomeActivitiesFilter(
      typeIn.map((index) => ActivityType.values.getOrFirst(index)).toList(),
      map['onFollowing'] ?? false,
      map['withViewerActivities'] ?? false,
    );
  }

  final bool onFollowing;
  final bool withViewerActivities;

  @override
  ActivitiesFilter copy() => HomeActivitiesFilter(
        [...typeIn],
        onFollowing,
        withViewerActivities,
      );

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

  Map<String, dynamic> toPersistenceMap() => {
        'activityTypeIn': typeIn.map((a) => a.index).toList(),
        'onFollowing': onFollowing,
        'withViewerActivities': withViewerActivities,
      };
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
