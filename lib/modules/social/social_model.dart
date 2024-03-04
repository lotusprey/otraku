import 'package:otraku/common/models/paged.dart';
import 'package:otraku/modules/user/user_models.dart';

class Social {
  const Social({
    this.following = const PagedWithTotal(),
    this.followers = const PagedWithTotal(),
  });

  final PagedWithTotal<UserItem> following;
  final PagedWithTotal<UserItem> followers;

  int getCount(SocialTab tab) => switch (tab) {
        SocialTab.following => following.total,
        SocialTab.followers => followers.total,
      };
}

enum SocialTab {
  following,
  followers;

  String get title => switch (this) {
        SocialTab.following => 'Following',
        SocialTab.followers => 'Followers',
      };
}
