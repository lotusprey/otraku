import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/user/friends_model.dart';
import 'package:otraku/user/user_models.dart';
import 'package:otraku/utils/api.dart';
import 'package:otraku/utils/graphql.dart';
import 'package:otraku/common/paged.dart';

final friendsProvider =
    StateNotifierProvider.autoDispose.family<FriendsNotifier, Friends, int>(
  (ref, userId) => FriendsNotifier(userId),
);

class FriendsNotifier extends StateNotifier<Friends> {
  FriendsNotifier(this.userId) : super(const Friends()) {
    _fetch(null);
  }

  final int userId;

  Future<void> fetch(bool onFollowing) => _fetch(onFollowing);

  Future<void> _fetch(bool? onFollowing) async {
    final variables = <String, dynamic>{'userId': userId};

    if (onFollowing == null) {
      variables['withFollowing'] = true;
      variables['withFollowers'] = true;
    } else if (onFollowing) {
      if (!(state.following.valueOrNull?.hasNext ?? true)) return;
      variables['withFollowing'] = true;
      variables['page'] = state.following.valueOrNull?.next ?? 1;
    } else {
      if (!(state.followers.valueOrNull?.hasNext ?? true)) return;
      variables['withFollowers'] = true;
      variables['page'] = state.followers.valueOrNull?.next ?? 1;
    }

    final data = await AsyncValue.guard(
      () => Api.get(GqlQuery.friends, variables),
    );

    var following = state.following;
    var followers = state.followers;

    if (onFollowing == null || onFollowing) {
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

    if (onFollowing == null || !onFollowing) {
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

    state = Friends(following: following, followers: followers);
  }
}
