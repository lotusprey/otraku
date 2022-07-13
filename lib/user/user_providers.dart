import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/user/user_models.dart';
import 'package:otraku/utils/api.dart';
import 'package:otraku/utils/graphql.dart';

/// Follow/Unfollow user. Returns `true` if successful.
Future<bool> toggleFollow(int userId) async {
  try {
    await Api.get(GqlMutation.toggleFollow, {'userId': userId});
    return true;
  } catch (_) {
    return false;
  }
}

final userProvider = FutureProvider.autoDispose.family<User, int>(
  (ref, userId) async {
    final data = await Api.get(GqlQuery.user, {'userId': userId});
    return User(data['User']);
  },
);
