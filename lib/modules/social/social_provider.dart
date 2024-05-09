import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/modules/social/social_model.dart';
import 'package:otraku/modules/user/user_models.dart';
import 'package:otraku/modules/viewer/api.dart';
import 'package:otraku/common/utils/graphql.dart';

final socialProvider =
    AsyncNotifierProvider.autoDispose.family<SocialNotifier, Social, int>(
  SocialNotifier.new,
);

class SocialNotifier extends AutoDisposeFamilyAsyncNotifier<Social, int> {
  @override
  FutureOr<Social> build(int arg) => _fetch(const Social(), null);

  Future<void> fetch(SocialTab tab) async {
    final oldState = state.valueOrNull ?? const Social();
    switch (tab) {
      case SocialTab.following:
        if (!oldState.following.hasNext) return;
      case SocialTab.followers:
        if (!oldState.followers.hasNext) return;
    }
    state = await AsyncValue.guard(() => _fetch(oldState, tab));
  }

  Future<Social> _fetch(Social oldState, SocialTab? tab) async {
    final variables = <String, dynamic>{'userId': arg};

    switch (tab) {
      case null:
        variables['withFollowing'] = true;
        variables['withFollowers'] = true;
        break;
      case SocialTab.following:
        variables['withFollowing'] = true;
        variables['page'] = oldState.following.next;
        break;
      case SocialTab.followers:
        variables['withFollowers'] = true;
        variables['page'] = oldState.followers.next;
        break;
    }

    final data = await Api.get(GqlQuery.friends, variables);

    var following = oldState.following;
    var followers = oldState.followers;

    if (tab == null || tab == SocialTab.following) {
      final map = data['following'];
      final items = <UserItem>[];
      for (final u in map['following']) {
        items.add(UserItem(u));
      }

      following = following.withNext(
        items,
        map['pageInfo']['hasNextPage'] ?? false,
        map['pageInfo']['total'],
      );
    }

    if (tab == null || tab == SocialTab.followers) {
      final map = data['followers'];
      final items = <UserItem>[];
      for (final u in map['followers']) {
        items.add(UserItem(u));
      }

      followers = followers.withNext(
        items,
        map['pageInfo']['hasNextPage'] ?? false,
        map['pageInfo']['total'],
      );
    }

    return Social(following: following, followers: followers);
  }
}
