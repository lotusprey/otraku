import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/common/models/paged.dart';
import 'package:otraku/modules/user/user_models.dart';

class Social {
  const Social({
    this.following = const AsyncValue.loading(),
    this.followers = const AsyncValue.loading(),
  });

  final AsyncValue<PagedWithTotal<UserItem>> following;
  final AsyncValue<PagedWithTotal<UserItem>> followers;

  int getCount(SocialTab tab) => switch (tab) {
        SocialTab.following => following.valueOrNull?.total ?? 0,
        SocialTab.followers => followers.valueOrNull?.total ?? 0,
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
