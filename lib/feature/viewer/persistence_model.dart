import 'package:flutter/material.dart';
import 'package:otraku/extension/enum_extension.dart';
import 'package:otraku/feature/activity/activities_filter_model.dart';
import 'package:otraku/feature/calendar/calendar_models.dart';
import 'package:otraku/feature/collection/collection_filter_model.dart';
import 'package:otraku/feature/collection/collection_models.dart';
import 'package:otraku/feature/discover/discover_filter_model.dart';
import 'package:otraku/feature/discover/discover_model.dart';
import 'package:otraku/feature/home/home_model.dart';
import 'package:otraku/feature/media/media_models.dart';
import 'package:otraku/util/theming.dart';

const appVersion = '1.8.0';

class Persistence {
  const Persistence({
    required this.systemColors,
    required this.accountGroup,
    required this.options,
    required this.appMeta,
    required this.animeCollectionMediaFilter,
    required this.mangaCollectionMediaFilter,
    required this.discoverMediaFilter,
    required this.homeActivitiesFilter,
    required this.calendarFilter,
  });

  factory Persistence.empty() => Persistence(
        systemColors: (lightPrimaryColor: null, darkPrimaryColor: null),
        accountGroup: AccountGroup.empty(),
        options: Options.empty(),
        appMeta: AppMeta.empty(),
        animeCollectionMediaFilter: CollectionMediaFilter(),
        mangaCollectionMediaFilter: CollectionMediaFilter(),
        discoverMediaFilter: DiscoverMediaFilter(MediaSort.titleRomaji),
        homeActivitiesFilter: HomeActivitiesFilter.empty(),
        calendarFilter: CalendarFilter.empty(),
      );

  factory Persistence.fromPersistenceMap(
    Map<dynamic, dynamic> map,
    Map<String, String> accessTokens,
  ) =>
      Persistence(
        systemColors: (lightPrimaryColor: null, darkPrimaryColor: null),
        accountGroup: AccountGroup.fromPersistenceMap(
          map['accountGroup'] ?? const {},
          accessTokens,
        ),
        options: Options.fromPersistenceMap(map['options'] ?? const {}),
        appMeta: AppMeta.fromPersistenceMap(map['appMeta'] ?? const {}),
        animeCollectionMediaFilter: CollectionMediaFilter.fromPersistenceMap(
          map['animeCollectionMediaFilter'] ?? const {},
        ),
        mangaCollectionMediaFilter: CollectionMediaFilter.fromPersistenceMap(
          map['mangaCollectionMediaFilter'] ?? const {},
        ),
        discoverMediaFilter: DiscoverMediaFilter.fromPersistenceMap(
          map['discoverMediaFilter'] ?? const {},
        ),
        homeActivitiesFilter: HomeActivitiesFilter.fromPersistenceMap(
          map['homeActivitiesFilter'] ?? const {},
        ),
        calendarFilter: CalendarFilter.fromPersistenceMap(
          map['calendarFilter'] ?? const {},
        ),
      );

  final SystemColors systemColors;
  final AccountGroup accountGroup;
  final Options options;
  final AppMeta appMeta;
  final CollectionMediaFilter animeCollectionMediaFilter;
  final CollectionMediaFilter mangaCollectionMediaFilter;
  final DiscoverMediaFilter discoverMediaFilter;
  final HomeActivitiesFilter homeActivitiesFilter;
  final CalendarFilter calendarFilter;

  Persistence copyWith({
    SystemColors? systemColors,
    AccountGroup? accountGroup,
    Options? options,
    AppMeta? appMeta,
    CollectionMediaFilter? animeCollectionMediaFilter,
    CollectionMediaFilter? mangaCollectionMediaFilter,
    DiscoverMediaFilter? discoverMediaFilter,
    HomeActivitiesFilter? homeActivitiesFilter,
    CalendarFilter? calendarFilter,
  }) =>
      Persistence(
        systemColors: systemColors ?? this.systemColors,
        accountGroup: accountGroup ?? this.accountGroup,
        options: options ?? this.options,
        appMeta: appMeta ?? this.appMeta,
        animeCollectionMediaFilter:
            animeCollectionMediaFilter ?? this.animeCollectionMediaFilter,
        mangaCollectionMediaFilter:
            mangaCollectionMediaFilter ?? this.mangaCollectionMediaFilter,
        discoverMediaFilter: discoverMediaFilter ?? this.discoverMediaFilter,
        homeActivitiesFilter: homeActivitiesFilter ?? this.homeActivitiesFilter,
        calendarFilter: calendarFilter ?? this.calendarFilter,
      );
}

typedef SystemColors = ({Color? lightPrimaryColor, Color? darkPrimaryColor});

class AccountGroup {
  const AccountGroup({required this.accounts, required this.accountIndex});

  factory AccountGroup.empty() => const AccountGroup(
        accounts: [],
        accountIndex: null,
      );

  factory AccountGroup.fromPersistenceMap(
    Map<dynamic, dynamic> map,
    Map<String, String> accessTokens,
  ) {
    final accounts = <Account>[];
    for (final a in map['accounts'] ?? const []) {
      final accessToken = accessTokens[Account.accessTokenKeyById(a['id'])];
      if (accessToken == null) continue;

      accounts.add(Account.fromPersistenceMap(a, accessToken));
    }

    int? accountIndex = map['accountIndex']?.clamp(0, accounts.length - 1);

    // Can't use an account whose token has expired.
    if (accountIndex != null &&
        accounts[accountIndex].expiration.compareTo(DateTime.now()) <= 0) {
      accountIndex = null;
    }

    return AccountGroup(accounts: accounts, accountIndex: accountIndex);
  }

  final List<Account> accounts;
  final int? accountIndex;

  Account? get account => accountIndex != null ? accounts[accountIndex!] : null;

  Map<String, dynamic> toPersistenceMap() => {
        'accounts': accounts.map((a) => a.toPersistenceMap()).toList(),
        'accountIndex': accountIndex,
      };
}

class Account {
  const Account({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.expiration,
    required this.accessToken,
  });

  factory Account.fromPersistenceMap(
          Map<dynamic, dynamic> map, String accessToken) =>
      Account(
        id: map['id'],
        name: map['name'],
        avatarUrl: map['avatarUrl'],
        expiration: map['expiration'],
        accessToken: accessToken,
      );

  final int id;
  final String name;
  final String avatarUrl;
  final DateTime expiration;
  final String accessToken;

  static String accessTokenKeyById(int id) => 'auth$id';

  Map<String, dynamic> toPersistenceMap() => {
        'id': id,
        'name': name,
        'avatarUrl': avatarUrl,
        'expiration': expiration,
      };
}

class Options {
  const Options({
    required this.themeMode,
    required this.themeBase,
    required this.highContrast,
    required this.homeTab,
    required this.discoverType,
    required this.imageQuality,
    required this.animeCollectionPreview,
    required this.mangaCollectionPreview,
    required this.confirmExit,
    required this.analogClock,
    required this.buttonOrientation,
    required this.discoverItemView,
    required this.collectionItemView,
    required this.collectionPreviewItemView,
  });

  factory Options.empty() => const Options(
        themeMode: ThemeMode.system,
        themeBase: null,
        highContrast: false,
        homeTab: HomeTab.feed,
        discoverType: DiscoverType.anime,
        imageQuality: ImageQuality.high,
        animeCollectionPreview: true,
        mangaCollectionPreview: true,
        confirmExit: false,
        analogClock: false,
        buttonOrientation: ButtonOrientation.auto,
        discoverItemView: DiscoverItemView.detailed,
        collectionItemView: CollectionItemView.detailed,
        collectionPreviewItemView: CollectionItemView.detailed,
      );

  factory Options.fromPersistenceMap(Map<dynamic, dynamic> map) => Options(
        themeMode: ThemeMode.values.getOrFirst(map['themeMode']),
        themeBase: ThemeBase.values.getOrNull(map['themeBase']),
        highContrast: map['highContrast'] ?? false,
        homeTab: HomeTab.values.getOrFirst(map['homeTab']),
        discoverType: DiscoverType.values.getOrFirst(map['discoverType']),
        imageQuality: ImageQuality.values.getOrNull(map['imageQuality']) ??
            ImageQuality.high,
        animeCollectionPreview: map['animeCollectionPreview'] ?? true,
        mangaCollectionPreview: map['mangaCollectionPreview'] ?? true,
        confirmExit: map['confirmExit'] ?? false,
        buttonOrientation: ButtonOrientation.values.getOrFirst(
          map['buttonOrientation'],
        ),
        analogClock: map['analogClock'] ?? false,
        discoverItemView: DiscoverItemView.values.getOrFirst(
          map['discoverItemView'],
        ),
        collectionItemView: CollectionItemView.values.getOrFirst(
          map['collectionItemView'],
        ),
        collectionPreviewItemView: CollectionItemView.values.getOrFirst(
          map['collectionPreviewItemView'],
        ),
      );

  final ThemeMode themeMode;
  final ThemeBase? themeBase;
  final bool highContrast;
  final HomeTab homeTab;
  final DiscoverType discoverType;
  final ImageQuality imageQuality;
  final bool animeCollectionPreview;
  final bool mangaCollectionPreview;
  final bool confirmExit;
  final bool analogClock;
  final ButtonOrientation buttonOrientation;
  final DiscoverItemView discoverItemView;
  final CollectionItemView collectionItemView;
  final CollectionItemView collectionPreviewItemView;

  Options copyWith({
    ThemeMode? themeMode,
    (ThemeBase?,)? themeBase,
    bool? highContrast,
    HomeTab? homeTab,
    DiscoverType? discoverType,
    ImageQuality? imageQuality,
    bool? animeCollectionPreview,
    bool? mangaCollectionPreview,
    bool? confirmExit,
    bool? analogClock,
    ButtonOrientation? buttonOrientation,
    DiscoverItemView? discoverItemView,
    CollectionItemView? collectionItemView,
    CollectionItemView? collectionPreviewItemView,
  }) =>
      Options(
        themeMode: themeMode ?? this.themeMode,
        themeBase: themeBase == null ? this.themeBase : themeBase.$1,
        highContrast: highContrast ?? this.highContrast,
        homeTab: homeTab ?? this.homeTab,
        discoverType: discoverType ?? this.discoverType,
        imageQuality: imageQuality ?? this.imageQuality,
        animeCollectionPreview:
            animeCollectionPreview ?? this.animeCollectionPreview,
        mangaCollectionPreview:
            mangaCollectionPreview ?? this.mangaCollectionPreview,
        confirmExit: confirmExit ?? this.confirmExit,
        buttonOrientation: buttonOrientation ?? this.buttonOrientation,
        analogClock: analogClock ?? this.analogClock,
        discoverItemView: discoverItemView ?? this.discoverItemView,
        collectionItemView: collectionItemView ?? this.collectionItemView,
        collectionPreviewItemView:
            collectionPreviewItemView ?? this.collectionPreviewItemView,
      );

  Map<String, dynamic> toPersistenceMap() => {
        'themeMode': themeMode.index,
        'themeBase': themeBase?.index,
        'highContrast': highContrast,
        'homeTab': homeTab.index,
        'discoverType': discoverType.index,
        'imageQuality': imageQuality.index,
        'animeCollectionPreview': animeCollectionPreview,
        'mangaCollectionPreview': mangaCollectionPreview,
        'confirmExit': confirmExit,
        'analogClock': analogClock,
        'buttonOrientation': buttonOrientation.index,
        'discoverItemView': discoverItemView.index,
        'collectionItemView': collectionItemView.index,
        'collectionPreviewItemView': collectionPreviewItemView.index,
      };
}

enum ImageQuality {
  veryHigh('Very High', 'extraLarge'),
  high('High', 'large'),
  medium('Medium', 'medium');

  const ImageQuality(this.label, this.value);

  final String label;
  final String value;
}

enum ButtonOrientation {
  auto,
  left,
  right,
}

class AppMeta {
  const AppMeta({
    required this.lastNotificationId,
    required this.lastAppVersion,
    required this.lastBackgroundJob,
  });

  factory AppMeta.empty() => const AppMeta(
        lastNotificationId: -1,
        lastAppVersion: '',
        lastBackgroundJob: null,
      );

  factory AppMeta.fromPersistenceMap(Map<dynamic, dynamic> map) => AppMeta(
        lastNotificationId: map['lastNotificationId'] ?? -1,
        lastAppVersion: map['lastAppVersion'] ?? '',
        lastBackgroundJob: map['lastBackgroundJob'],
      );

  final int lastNotificationId;
  final String lastAppVersion;
  final DateTime? lastBackgroundJob;

  Map<String, dynamic> toPersistenceMap() => {
        'lastNotificationId': lastNotificationId,
        'lastAppVersion': lastAppVersion,
        'lastBackgroundJob': lastBackgroundJob,
      };
}
