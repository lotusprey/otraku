sealed class ActivitiesTag {
  const ActivitiesTag();

  String toQueryParam() => switch (this) {
        HomeActivitiesTag() => 'home',
        UserActivitiesTag(:final userId) => 'user:$userId',
        MediaActivitiesTag(:final mediaId) => 'media:$mediaId',
      };

  static ActivitiesTag? fromQueryParam(String param) {
    if (param == 'home') {
      return HomeActivitiesTag.instance;
    } else if (param.startsWith('user:')) {
      final userId = int.tryParse(param.substring(5));
      if (userId != null) {
        return UserActivitiesTag(userId);
      }
    } else if (param.startsWith('media:')) {
      final mediaId = int.tryParse(param.substring(6));
      if (mediaId != null) {
        return MediaActivitiesTag(mediaId);
      }
    }

    return null;
  }
}

class HomeActivitiesTag extends ActivitiesTag {
  const HomeActivitiesTag._();

  static const instance = HomeActivitiesTag._();
}

class UserActivitiesTag extends ActivitiesTag {
  const UserActivitiesTag(this.userId);

  final int userId;

  @override
  bool operator ==(Object other) => other is UserActivitiesTag && userId == other.userId;

  @override
  int get hashCode => userId.hashCode;
}

class MediaActivitiesTag extends ActivitiesTag {
  const MediaActivitiesTag(this.mediaId);

  final int mediaId;

  @override
  bool operator ==(Object other) => other is MediaActivitiesTag && mediaId == other.mediaId;

  @override
  int get hashCode => mediaId.hashCode;
}
