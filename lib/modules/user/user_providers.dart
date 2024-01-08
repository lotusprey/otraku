import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/modules/user/user_models.dart';
import 'package:otraku/common/utils/api.dart';
import 'package:otraku/common/utils/graphql.dart';

/// Follow/Unfollow user. Returns `true` if successful.
Future<bool> toggleFollow(int userId) async {
  try {
    await Api.get(GqlMutation.toggleFollow, {'userId': userId});
    return true;
  } catch (_) {
    return false;
  }
}

typedef UserTag = ({int? id, String? name});
UserTag idUserTag(int id) => (id: id, name: null);
UserTag nameUserTag(String name) => (id: null, name: name);

final userProvider = FutureProvider.autoDispose.family<User, UserTag>(
  (ref, tag) async {
    final data = await Api.get(
      GqlQuery.user,
      tag.id != null ? {'id': tag.id} : {'name': tag.name},
    );
    return User(data['User']);
  },
);
