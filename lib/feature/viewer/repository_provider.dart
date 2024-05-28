import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:otraku/feature/viewer/account_model.dart';
import 'package:otraku/feature/viewer/repository_model.dart';
import 'package:otraku/util/persistence.dart';

final repositoryProvider = NotifierProvider<RepositoryNotifier, Repository>(
  RepositoryNotifier.new,
);

class RepositoryNotifier extends Notifier<Repository> {
  @override
  Repository build() => const Repository.guest();

  Future<bool> init() async {
    final account = Persistence().selectedAccount;
    if (account == null) return false;

    if (DateTime.now().compareTo(account.expiration) >= 0) return false;

    final accessToken = await const FlutterSecureStorage().read(
      key: account.tokenPersistenceKey,
    );
    if (accessToken == null) return false;

    state = Repository(accessToken);
    return true;
  }

  Future<bool> selectAccount(int index) async {
    if (index < 0 || index >= Persistence().accounts.length) return false;

    final account = Persistence().accounts[index];
    if (DateTime.now().compareTo(account.expiration) >= 0) return false;

    Persistence().selectedAccountIndex = index;
    final accessToken = await const FlutterSecureStorage().read(
      key: account.tokenPersistenceKey,
    );

    if (accessToken == null) {
      Persistence().selectedAccountIndex = null;
      return false;
    }

    state = Repository(accessToken);
    return true;
  }

  void unselectAccount() {
    state = const Repository.guest();
    Persistence().selectedAccountIndex = null;
  }

  Future<bool> addAccount(
    String token,
    int secondsLeftBeforeExpiration,
  ) async {
    try {
      final data = await Repository(token).request(
        'query Viewer {Viewer {id name avatar {large}}}',
      );

      final id = data['Viewer']?['id'];
      final name = data['Viewer']?['name'];
      final avatarUrl = data['Viewer']?['avatar']?['large'];
      if (id == null || name == null || avatarUrl == null) {
        return false;
      }

      if (Persistence().accounts.indexWhere((a) => a.id == id) > -1) {
        return true;
      }

      final expiration = DateTime.now().add(
        Duration(seconds: secondsLeftBeforeExpiration, days: -1),
      );

      final account = Account(
        id: id,
        name: name,
        avatarUrl: avatarUrl,
        expiration: expiration,
      );

      Persistence().accounts = [...Persistence().accounts, account];
      await const FlutterSecureStorage().write(
        key: account.tokenPersistenceKey,
        value: token,
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> removeAccount(int index) async {
    final account = Persistence().accounts.elementAtOrNull(index);
    if (account == null) return;

    Persistence().selectedAccountIndex = null;

    await const FlutterSecureStorage().delete(key: account.tokenPersistenceKey);
    Persistence().accounts.removeAt(index);
    Persistence().accounts = Persistence().accounts;
  }
}
