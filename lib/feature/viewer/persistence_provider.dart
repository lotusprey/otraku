import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'package:otraku/feature/activity/activities_filter_model.dart';
import 'package:otraku/feature/calendar/calendar_models.dart';
import 'package:otraku/feature/collection/collection_filter_model.dart';
import 'package:otraku/feature/discover/discover_filter_model.dart';
import 'package:otraku/feature/viewer/persistence_model.dart';
import 'package:otraku/util/background_handler.dart';
import 'package:path_provider/path_provider.dart';

final persistenceProvider = NotifierProvider<PersistenceNotifier, Persistence>(
  PersistenceNotifier.new,
);

final viewerIdProvider = persistenceProvider.select((s) => s.accountGroup.account?.id);

class PersistenceNotifier extends Notifier<Persistence> {
  late Box<Map<dynamic, dynamic>> _box;

  @override
  Persistence build() => .empty();

  Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Configure home directory, if not in the browser.
    if (!kIsWeb) Hive.init((await getApplicationDocumentsDirectory()).path);

    _box = await Hive.openBox('persistence');
    final accessTokens = await const FlutterSecureStorage().readAll();

    state = .fromPersistenceMap(_box.toMap(), accessTokens);
  }

  void cacheSystemPrimaryColors(SystemColors systemColors) {
    state = state.copyWith(systemColors: systemColors);
  }

  void setOptions(Options options) {
    _box.put('options', options.toPersistenceMap());
    state = state.copyWith(options: options);
  }

  void setAppMeta(AppMeta appMeta) {
    _box.put('appMeta', appMeta.toPersistenceMap());
    state = state.copyWith(appMeta: appMeta);
  }

  void setAnimeCollectionMediaFilter(CollectionMediaFilter mediaFilter) {
    _box.put('animeCollectionMediaFilter', mediaFilter.toPersistenceMap());
    state = state.copyWith(animeCollectionMediaFilter: mediaFilter);
  }

  void setMangaCollectionMediaFilter(CollectionMediaFilter mediaFilter) {
    _box.put('mangaCollectionMediaFilter', mediaFilter.toPersistenceMap());
    state = state.copyWith(mangaCollectionMediaFilter: mediaFilter);
  }

  void setDiscoverMediaFilter(DiscoverMediaFilter discoverMediaFilter) {
    _box.put('discoverMediaFilter', discoverMediaFilter.toPersistenceMap());
    state = state.copyWith(discoverMediaFilter: discoverMediaFilter);
  }

  void setHomeActivitiesFilter(HomeActivitiesFilter homeActivitiesFilter) {
    _box.put('homeActivitiesFilter', homeActivitiesFilter.toPersistenceMap());
    state = state.copyWith(homeActivitiesFilter: homeActivitiesFilter);
  }

  void setCalendarFilter(CalendarFilter calendarFilter) {
    _box.put('calendarFilter', calendarFilter.toPersistenceMap());
    state = state.copyWith(calendarFilter: calendarFilter);
  }

  void refreshViewerDetails(String newName, String newAvatarUrl) {
    final accounts = state.accountGroup.accounts;
    final accountIndex = state.accountGroup.accountIndex;

    if (accountIndex == null) return;
    final account = accounts[accountIndex];

    if (account.name == newName && account.avatarUrl == newAvatarUrl) return;

    _setAccountGroup(
      AccountGroup(
        accounts: [
          ...accounts.sublist(0, accountIndex),
          Account(
            name: newName,
            avatarUrl: newAvatarUrl,
            id: account.id,
            expiration: account.expiration,
            accessToken: account.accessToken,
          ),
          ...accounts.sublist(accountIndex + 1),
        ],
        accountIndex: accountIndex,
      ),
    );
  }

  /// Switches active account.
  /// Don't switch to an account whose token has expired.
  void switchAccount(int? index) {
    final accountGroup = state.accountGroup;

    if (index == accountGroup.accountIndex) return;
    if (index != null && (index < 0 || index >= accountGroup.accounts.length)) {
      return;
    }

    if (index == null) BackgroundHandler.clearNotifications();

    _setAccountGroup(AccountGroup(accountIndex: index, accounts: accountGroup.accounts));
  }

  Future<void> addAccount(Account account) async {
    final accounts = state.accountGroup.accounts;
    final accountIndex = state.accountGroup.accountIndex;

    await const FlutterSecureStorage().write(
      key: Account.accessTokenKeyById(account.id),
      value: account.accessToken,
    );

    for (int i = 0; i < accounts.length; i++) {
      if (accounts[i].id == account.id) {
        _setAccountGroup(
          AccountGroup(
            accounts: [...accounts.sublist(0, i), account, ...accounts.sublist(i + 1)],
            accountIndex: accountIndex,
          ),
        );

        switchAccount(i);
        return;
      }
    }

    _setAccountGroup(AccountGroup(accounts: [...accounts, account], accountIndex: accountIndex));

    switchAccount(state.accountGroup.accounts.length - 1);
  }

  Future<void> removeAccount(int index) async {
    final accountGroup = state.accountGroup;

    if (index == accountGroup.accountIndex) return;
    if (index < 0 || index >= accountGroup.accounts.length) return;

    final account = accountGroup.accounts[index];
    await const FlutterSecureStorage().delete(key: Account.accessTokenKeyById(account.id));

    _setAccountGroup(
      AccountGroup(
        accounts: [
          ...accountGroup.accounts.sublist(0, index),
          ...accountGroup.accounts.sublist(index + 1),
        ],
        accountIndex: accountGroup.accountIndex,
      ),
    );
  }

  /// Persists the account changes, but doesn't affect secure storage.
  /// Token changes must be handled separately.
  void _setAccountGroup(AccountGroup accountGroup) {
    _box.put('accountGroup', accountGroup.toPersistenceMap());
    state = state.copyWith(accountGroup: accountGroup);
  }
}
