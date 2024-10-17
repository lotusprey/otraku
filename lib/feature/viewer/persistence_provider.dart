import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'package:otraku/feature/activity/activities_filter_model.dart';
import 'package:otraku/feature/calendar/calendar_models.dart';
import 'package:otraku/feature/viewer/persistence_model.dart';
import 'package:path_provider/path_provider.dart';

final persistenceProvider = NotifierProvider<PersistenceNotifier, Persistence1>(
  PersistenceNotifier.new,
);

class PersistenceNotifier extends Notifier<Persistence1> {
  late Box<Map<String, dynamic>> _box;

  @override
  Persistence1 build() => Persistence1.empty();

  Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Configure home directory, if not in the browser.
    if (!kIsWeb) Hive.init((await getApplicationDocumentsDirectory()).path);

    _box = await Hive.openBox('persistence');
    final accessTokens = await const FlutterSecureStorage().readAll();

    state = Persistence1.fromMap(_box.toMap(), accessTokens);
  }

  void setOptions(Options options) {
    _box.put('options', options.toMap());
    state = Persistence1(
      options: options,
      accountGroup: state.accountGroup,
      appMeta: state.appMeta,
      homeActivitiesFilter: state.homeActivitiesFilter,
      calendarFilter: state.calendarFilter,
    );
  }

  void setAppMeta(AppMeta appMeta) {
    _box.put('appMeta', appMeta.toMap());
    state = Persistence1(
      appMeta: appMeta,
      accountGroup: state.accountGroup,
      options: state.options,
      homeActivitiesFilter: state.homeActivitiesFilter,
      calendarFilter: state.calendarFilter,
    );
  }

  void setHomeActivitiesFilter(HomeActivitiesFilter homeActivitiesFilter) {
    _box.put('homeActivitiesFilter', homeActivitiesFilter.toMap());
    state = Persistence1(
      homeActivitiesFilter: homeActivitiesFilter,
      accountGroup: state.accountGroup,
      options: state.options,
      appMeta: state.appMeta,
      calendarFilter: state.calendarFilter,
    );
  }

  void setCalendarFilter(CalendarFilter calendarFilter) {
    _box.put('calendarFilter', calendarFilter.toMap());
    state = Persistence1(
      calendarFilter: calendarFilter,
      accountGroup: state.accountGroup,
      options: state.options,
      appMeta: state.appMeta,
      homeActivitiesFilter: state.homeActivitiesFilter,
    );
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
          ...accounts.sublist(accountIndex + 1)
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

    _setAccountGroup(
      AccountGroup(
        accountIndex: index,
        accounts: accountGroup.accounts,
      ),
    );
  }

  Future<void> addAccount(Account account) async {
    final accountGroup = state.accountGroup;
    for (final a in accountGroup.accounts) {
      if (a.id == account.id) return;
    }

    await const FlutterSecureStorage().write(
      key: Account.accessTokenKeyById(account.id),
      value: account.accessToken,
    );

    _setAccountGroup(
      AccountGroup(
        accounts: [...accountGroup.accounts, account],
        accountIndex: accountGroup.accountIndex,
      ),
    );
  }

  Future<void> removeAccount(int index) async {
    final accountGroup = state.accountGroup;

    if (index == accountGroup.accountIndex) return;
    if (index < 0 || index >= accountGroup.accounts.length) return;

    final account = accountGroup.accounts[index];
    await const FlutterSecureStorage().delete(
      key: Account.accessTokenKeyById(account.id),
    );

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
    _box.put('accountGroup', accountGroup.toMap());

    state = Persistence1(
      accountGroup: accountGroup,
      options: state.options,
      appMeta: state.appMeta,
      homeActivitiesFilter: state.homeActivitiesFilter,
      calendarFilter: state.calendarFilter,
    );
  }
}
