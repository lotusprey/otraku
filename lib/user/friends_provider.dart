import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/user/user_models.dart';
import 'package:otraku/utils/api.dart';
import 'package:otraku/utils/graphql.dart';
import 'package:otraku/common/paged.dart';

final friendsProvider =
    ChangeNotifierProvider.autoDispose.family<FriendsNotifier, int>(
  (ref, userId) => FriendsNotifier(userId),
);

class FriendsNotifier extends ChangeNotifier {
  FriendsNotifier(this.userId);

  final int userId;

  bool _onFollowing = false;
  int _followingCount = 0;
  int _followersCount = 0;
  var _following = const AsyncValue.data(Paged<UserItem>());
  var _followers = const AsyncValue.data(Paged<UserItem>());

  int getCount(bool onFollowing) {
    _onFollowing = onFollowing;
    if (onFollowing) {
      if (_following is AsyncData &&
          _following.value!.items.isEmpty &&
          _following.value!.hasNext) {
        _following = const AsyncValue.loading();
        fetch();
      }

      return _followingCount;
    }

    if (_followers is AsyncData &&
        _followers.value!.items.isEmpty &&
        _followers.value!.hasNext) {
      _followers = const AsyncValue.loading();
      fetch();
    }
    return _followersCount;
  }

  AsyncValue<Paged<UserItem>> get following => _following;
  AsyncValue<Paged<UserItem>> get followers => _followers;

  Future<void> fetch() async {
    final onFollowing = _onFollowing;
    if (onFollowing && !(_following.valueOrNull?.hasNext ?? true) ||
        !onFollowing && !(_followers.valueOrNull?.hasNext ?? true)) return;

    var users = onFollowing ? _following : _followers;

    users = await AsyncValue.guard(() async {
      final value = users.valueOrNull ?? const Paged();

      final data = await Api.get(GqlQuery.friends, {
        'userId': userId,
        'page': value.next,
        'withFollowing': onFollowing,
        'withFollowers': !onFollowing,
      });

      final key = onFollowing ? 'following' : 'followers';
      final count = data[key]['pageInfo']['total'] ?? 0;
      if (onFollowing) {
        if (_followingCount == 0) _followingCount = count;
      } else {
        if (_followersCount == 0) _followersCount = count;
      }

      final items = <UserItem>[];
      for (final u in data[key][key]) {
        items.add(UserItem(u));
      }

      return value.withNext(
        items,
        data[key]['pageInfo']['hasNextPage'] ?? false,
      );
    });

    onFollowing ? _following = users : _followers = users;
    notifyListeners();
  }
}
