import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/feature/user/user_models.dart';
import 'package:otraku/feature/viewer/repository_provider.dart';
import 'package:otraku/util/graphql.dart';

typedef UserTag = ({int? id, String? name});

UserTag idUserTag(int id) => (id: id, name: null);

UserTag nameUserTag(String name) => (id: null, name: name);

final userProvider =
    AsyncNotifierProvider.autoDispose.family<UserNotifier, User, UserTag>(
  UserNotifier.new,
);

class UserNotifier extends AutoDisposeFamilyAsyncNotifier<User, UserTag> {
  @override
  FutureOr<User> build(UserTag arg) async {
    final data = await ref.read(repositoryProvider).request(
          GqlQuery.user,
          arg.id != null ? {'id': arg.id} : {'name': arg.name},
        );
    return User(data['User']);
  }

  Future<bool> toggleFollow(int userId) {
    return ref.read(repositoryProvider).request(
      GqlMutation.toggleFollow,
      {'userId': userId},
    ).then((_) => true, onError: (_) => false);
  }
}
