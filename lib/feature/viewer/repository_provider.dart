import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/feature/viewer/persistence_model.dart';
import 'package:otraku/feature/viewer/persistence_provider.dart';
import 'package:otraku/feature/viewer/repository_model.dart';

final repositoryProvider = NotifierProvider<RepositoryNotifier, Repository>(RepositoryNotifier.new);

class RepositoryNotifier extends Notifier<Repository> {
  @override
  Repository build() {
    final accessToken = ref.watch(
      persistenceProvider.select((s) => s.accountGroup.account?.accessToken),
    );

    return Repository(accessToken);
  }

  Future<Account?> initAccount(String token, int secondsUntilExpiration) async {
    try {
      final data = await Repository(
        token,
      ).request('query Viewer {Viewer {id name avatar {large}}}');

      final id = data['Viewer']?['id'];
      final name = data['Viewer']?['name'];
      final avatarUrl = data['Viewer']?['avatar']?['large'];
      if (id == null || name == null || avatarUrl == null) {
        return null;
      }

      final expiration = DateTime.now().add(Duration(seconds: secondsUntilExpiration, days: -1));

      return Account(
        id: id,
        name: name,
        avatarUrl: avatarUrl,
        expiration: expiration,
        accessToken: token,
      );
    } catch (_) {
      return null;
    }
  }
}
