import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/modules/social/social_model.dart';
import 'package:otraku/modules/user/user_models.dart';
import 'package:otraku/common/utils/api.dart';
import 'package:otraku/common/utils/graphql.dart';
import 'package:otraku/common/models/paged.dart';

final socialProvider =
    StateNotifierProvider.autoDispose.family<SocialNotifier, Social, int>(
  (ref, userId) => SocialNotifier(userId),
);

class SocialNotifier extends StateNotifier<Social> {
  SocialNotifier(this.userId) : super(const Social()) {
    _fetch(null);
  }

  final int userId;

  Future<void> fetch(SocialTab tab) => _fetch(tab);

  Future<void> _fetch(SocialTab? tab) async {
    final variables = <String, dynamic>{'userId': userId};

    switch (tab) {
      case null:
        variables['withFollowing'] = true;
        variables['withFollowers'] = true;
        break;
      case SocialTab.following:
        if (!(state.following.valueOrNull?.hasNext ?? true)) return;
        variables['withFollowing'] = true;
        variables['page'] = state.following.valueOrNull?.next ?? 1;
        break;
      case SocialTab.followers:
        if (!(state.followers.valueOrNull?.hasNext ?? true)) return;
        variables['withFollowers'] = true;
        variables['page'] = state.followers.valueOrNull?.next ?? 1;
        break;
    }

    final data = await AsyncValue.guard(
      () => Api.get(GqlQuery.friends, variables),
    );

    var following = state.following;
    var followers = state.followers;

    if (tab == null || tab == SocialTab.following) {
      following = await AsyncValue.guard(() {
        if (data.hasError) throw data.error!;
        final map = data.value!['following'];
        final value = following.valueOrNull ?? const PagedWithTotal();

        final items = <UserItem>[];
        for (final u in map['following']) {
          items.add(UserItem(u));
        }

        return Future.value(value.withNext(
          items,
          map['pageInfo']['hasNextPage'] ?? false,
          map['pageInfo']['total'],
        ));
      });
    }

    if (tab == null || tab == SocialTab.followers) {
      followers = await AsyncValue.guard(() {
        if (data.hasError) throw data.error!;
        final map = data.value!['followers'];
        final value = followers.valueOrNull ?? const PagedWithTotal();

        final items = <UserItem>[];
        for (final u in map['followers']) {
          items.add(UserItem(u));
        }

        return Future.value(value.withNext(
          items,
          map['pageInfo']['hasNextPage'] ?? false,
          map['pageInfo']['total'],
        ));
      });
    }

    state = Social(following: following, followers: followers);
  }
}
