import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/common/paged.dart';
import 'package:otraku/user/user_models.dart';

class Friends {
  const Friends({
    this.following = const AsyncValue.loading(),
    this.followers = const AsyncValue.loading(),
  });

  final AsyncValue<PagedWithTotal<UserItem>> following;
  final AsyncValue<PagedWithTotal<UserItem>> followers;

  int getCount(bool onFollowing) => onFollowing
      ? following.valueOrNull?.total ?? 0
      : followers.valueOrNull?.total ?? 0;
}
