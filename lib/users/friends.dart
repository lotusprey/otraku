import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/utils/client.dart';
import 'package:otraku/utils/graphql.dart';
import 'package:otraku/utils/pagination.dart';

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
  var _following = AsyncValue.data(Pagination<UserItem>());
  var _followers = AsyncValue.data(Pagination<UserItem>());

  int get followingCount => _followingCount;
  int get followersCount => _followersCount;

  AsyncValue<Pagination<UserItem>> get following {
    _onFollowing = true;
    if (_following is AsyncData &&
        _following.value!.items.isEmpty &&
        _following.value!.hasNext) {
      _following = const AsyncValue.loading();
      fetch();
    }
    return _following;
  }

  AsyncValue<Pagination<UserItem>> get followers {
    _onFollowing = false;
    if (_followers is AsyncData &&
        _followers.value!.items.isEmpty &&
        _followers.value!.hasNext) {
      _followers = const AsyncValue.loading();
      fetch();
    }
    return _followers;
  }

  Future<void> fetch() async {
    final onFollowing = _onFollowing;
    var users = onFollowing ? _following : _followers;

    users = await AsyncValue.guard(() async {
      final value = users.value ?? Pagination();

      final data = await Client.get(GqlQuery.friends, {
        'userId': userId,
        'page': value.next,
        'withFollowing': onFollowing,
        'withFollowers': !onFollowing,
      });

      final key = onFollowing ? 'following' : 'followers';
      final count = data[key]['pageInfo']?['total'] ?? 0;
      onFollowing ? _followingCount = count : _followersCount = count;

      final items = <UserItem>[];
      for (final u in data[key][key]) items.add(UserItem(u));

      return value.append(
        items,
        data[key]['pageInfo']['hasNextPage'] ?? false,
      );
    });

    onFollowing ? _following = users : _followers = users;
    notifyListeners();
  }
}

class UserItem {
  UserItem._({required this.id, required this.name, required this.imageUrl});

  factory UserItem(Map<String, dynamic> map) => UserItem._(
        id: map['id'],
        name: map['name'],
        imageUrl: map['avatar']['large'],
      );

  final int id;
  final String name;
  final String imageUrl;
}
