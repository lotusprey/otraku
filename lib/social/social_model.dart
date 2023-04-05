import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/common/paged.dart';
import 'package:otraku/user/user_models.dart';

class Social {
  const Social({
    this.following = const AsyncValue.loading(),
    this.followers = const AsyncValue.loading(),
  });

  final AsyncValue<PagedWithTotal<UserItem>> following;
  final AsyncValue<PagedWithTotal<UserItem>> followers;

  int getCount(SocialTab tab) {
    switch (tab) {
      case SocialTab.following:
        return following.valueOrNull?.total ?? 0;
      case SocialTab.followers:
        return followers.valueOrNull?.total ?? 0;
    }
  }
}

enum SocialTab {
  following,
  followers;

  String get title {
    switch (this) {
      case SocialTab.following:
        return 'Following';
      case SocialTab.followers:
        return 'Followers';
    }
  }
}
