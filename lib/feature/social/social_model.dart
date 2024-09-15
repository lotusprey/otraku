import 'package:otraku/feature/user/user_item_model.dart';
import 'package:otraku/util/paged.dart';

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
