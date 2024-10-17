import 'package:flutter/material.dart';
import 'package:otraku/extension/enum_extension.dart';
import 'package:otraku/feature/activity/activities_filter_model.dart';
import 'package:otraku/feature/calendar/calendar_models.dart';
import 'package:otraku/feature/collection/collection_models.dart';
import 'package:otraku/feature/discover/discover_model.dart';
import 'package:otraku/feature/home/home_model.dart';
import 'package:otraku/feature/media/media_models.dart';
import 'package:otraku/util/theming.dart';

const appVersion = '1.5.3';

class Persistence1 {
  const Persistence1({
    required this.accountGroup,
    required this.options,
    required this.appMeta,
    required this.homeActivitiesFilter,
    required this.calendarFilter,
  });

  factory Persistence1.empty() => Persistence1(
        accountGroup: AccountGroup.empty(),
        options: Options.empty(),
        appMeta: AppMeta.empty(),
        homeActivitiesFilter: HomeActivitiesFilter.empty(),
        calendarFilter: CalendarFilter.empty(),
      );

  factory Persistence1.fromMap(
    Map<dynamic, dynamic> map,
    Map<String, String> accessTokens,
  ) =>
      Persistence1(
        accountGroup: AccountGroup.fromMap(map['accountGroup'], accessTokens),
        options: Options.fromMap(map['options']),
        appMeta: AppMeta.fromMap(map['appMeta']),
        homeActivitiesFilter: HomeActivitiesFilter.fromMap(
          map['homeActivitiesFilter'],
        ),
        calendarFilter: CalendarFilter.fromMap(map['calendarFilter']),
      );

  final AccountGroup accountGroup;
  final Options options;
  final AppMeta appMeta;
  final HomeActivitiesFilter homeActivitiesFilter;
  final CalendarFilter calendarFilter;

  Persistence1 copyWith({
    AccountGroup? accountGroup,
    Options? options,
    AppMeta? appMeta,
    HomeActivitiesFilter? homeActivitiesFilter,
    CalendarFilter? calendarFilter,
  }) =>
      Persistence1(
        accountGroup: accountGroup ?? this.accountGroup,
        options: options ?? this.options,
        appMeta: appMeta ?? this.appMeta,
        homeActivitiesFilter: homeActivitiesFilter ?? this.homeActivitiesFilter,
        calendarFilter: calendarFilter ?? this.calendarFilter,
      );
}

class AccountGroup {
  const AccountGroup({required this.accounts, required this.accountIndex});

  factory AccountGroup.empty() => const AccountGroup(
        accounts: [],
        accountIndex: null,
      );

  factory AccountGroup.fromMap(
    Map<String, dynamic> map,
    Map<String, String> accessTokens,
  ) {
    final accounts = <Account>[];
    for (final a in map['accounts']) {
      final accessToken = accessTokens[Account.accessTokenKeyById(a['id'])];
      if (accessToken == null) continue;

      accounts.add(Account.fromMap(a, accessToken));
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

  Map<String, dynamic> toMap() => {
        'accounts': accounts.map((a) => a.toMap()).toList(),
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

  factory Account.fromMap(Map<String, dynamic> map, String accessToken) =>
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

  Map<String, dynamic> toMap() => {
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
    required this.defaultHomeTab,
    required this.defaultDiscoverType,
    required this.defaultAnimeSort,
    required this.defaultMangaSort,
    required this.defaultDiscoverSort,
    required this.imageQuality,
    required this.animeCollectionPreview,
    required this.mangaCollectionPreview,
    required this.airingSortForAnimePreview,
    required this.confirmExit,
    required this.leftHanded,
    required this.analogueClock,
    required this.discoverItemView,
    required this.collectionItemView,
    required this.collectionPreviewItemView,
  });

  factory Options.empty() => const Options(
        themeMode: ThemeMode.system,
        themeBase: null,
        highContrast: false,
        defaultHomeTab: HomeTab.feed,
        defaultDiscoverType: DiscoverType.anime,
        defaultAnimeSort: EntrySort.title,
        defaultMangaSort: EntrySort.title,
        defaultDiscoverSort: MediaSort.trendingDesc,
        imageQuality: ImageQuality.High,
        animeCollectionPreview: true,
        mangaCollectionPreview: true,
        airingSortForAnimePreview: true,
        confirmExit: false,
        leftHanded: false,
        analogueClock: false,
        discoverItemView: DiscoverItemView.detailedList,
        collectionItemView: CollectionItemView.detailedList,
        collectionPreviewItemView: CollectionItemView.detailedList,
      );

  factory Options.fromMap(Map<String, dynamic> map) => Options(
        themeMode: ThemeMode.values.getOrFirst(map['themeMode']),
        themeBase: ThemeBase.values.getOrFirst(map['themeBase']),
        highContrast: map['highContrast'] ?? false,
        defaultHomeTab: HomeTab.values.getOrFirst(map['defaultHomeTab']),
        defaultDiscoverType: DiscoverType.values.getOrFirst(
          map['defaultDiscoverType'],
        ),
        defaultAnimeSort: EntrySort.values.getOrFirst(
          map['defaultAnimeSort'],
        ),
        defaultMangaSort: EntrySort.values.getOrFirst(
          map['defaultMangaSort'],
        ),
        defaultDiscoverSort: MediaSort.values.getOrFirst(
          map['defaultDiscoverSort'],
        ),
        imageQuality: ImageQuality.values.getOrFirst(map['imageQuality']),
        animeCollectionPreview: map['animeCollectionPreview'] ?? true,
        mangaCollectionPreview: map['mangaCollectionPreview'] ?? true,
        airingSortForAnimePreview: map['airingSortForAnimePreview'] ?? true,
        confirmExit: map['confirmExit'] ?? false,
        leftHanded: map['leftHanded'] ?? false,
        analogueClock: map['analogueClock'] ?? false,
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
  final HomeTab defaultHomeTab;
  final DiscoverType defaultDiscoverType;
  final EntrySort defaultAnimeSort;
  final EntrySort defaultMangaSort;
  final MediaSort defaultDiscoverSort;
  final ImageQuality imageQuality;
  final bool animeCollectionPreview;
  final bool mangaCollectionPreview;
  final bool airingSortForAnimePreview;
  final bool confirmExit;
  final bool leftHanded;
  final bool analogueClock;
  final DiscoverItemView discoverItemView;
  final CollectionItemView collectionItemView;
  final CollectionItemView collectionPreviewItemView;

  Options copyWith({
    ThemeMode? themeMode,
    ThemeBase? Function()? themeBase,
    bool? highContrast,
    HomeTab? defaultHomeTab,
    DiscoverType? defaultDiscoverType,
    EntrySort? defaultAnimeSort,
    EntrySort? defaultMangaSort,
    MediaSort? defaultDiscoverSort,
    ImageQuality? imageQuality,
    bool? animeCollectionPreview,
    bool? mangaCollectionPreview,
    bool? airingSortForAnimePreview,
    bool? confirmExit,
    bool? leftHanded,
    bool? analogueClock,
    DiscoverItemView? discoverItemView,
    CollectionItemView? collectionItemView,
    CollectionItemView? collectionPreviewItemView,
  }) =>
      Options(
        themeMode: themeMode ?? this.themeMode,
        themeBase: themeBase != null ? themeBase() : this.themeBase,
        highContrast: highContrast ?? this.highContrast,
        defaultHomeTab: defaultHomeTab ?? this.defaultHomeTab,
        defaultDiscoverType: defaultDiscoverType ?? this.defaultDiscoverType,
        defaultAnimeSort: defaultAnimeSort ?? this.defaultAnimeSort,
        defaultMangaSort: defaultMangaSort ?? this.defaultMangaSort,
        defaultDiscoverSort: defaultDiscoverSort ?? this.defaultDiscoverSort,
        imageQuality: imageQuality ?? this.imageQuality,
        animeCollectionPreview:
            animeCollectionPreview ?? this.animeCollectionPreview,
        mangaCollectionPreview:
            mangaCollectionPreview ?? this.mangaCollectionPreview,
        airingSortForAnimePreview:
            airingSortForAnimePreview ?? this.airingSortForAnimePreview,
        confirmExit: confirmExit ?? this.confirmExit,
        leftHanded: leftHanded ?? this.leftHanded,
        analogueClock: analogueClock ?? this.analogueClock,
        discoverItemView: discoverItemView ?? this.discoverItemView,
        collectionItemView: collectionItemView ?? this.collectionItemView,
        collectionPreviewItemView:
            collectionPreviewItemView ?? this.collectionPreviewItemView,
      );

  Map<String, dynamic> toMap() => {
        'themeMode': themeMode.index,
        'themeBase': themeBase?.index,
        'highContrast': highContrast,
        'defaultHomeTab': defaultHomeTab.index,
        'defaultDiscoverType': defaultDiscoverType.index,
        'defaultAnimeSort': defaultAnimeSort.index,
        'defaultMangaSort': defaultMangaSort.index,
        'defaultDiscoverSort': defaultDiscoverSort.index,
        'imageQuality': imageQuality.index,
        'animeCollectionPreview': animeCollectionPreview,
        'mangaCollectionPreview': mangaCollectionPreview,
        'airingSortForAnimePreview': airingSortForAnimePreview,
        'confirmExit': confirmExit,
        'leftHanded': leftHanded,
        'analogueClock': analogueClock,
        'discoverItemView': discoverItemView.index,
        'collectionItemView': collectionItemView.index,
        'collectionPreviewItemView': collectionPreviewItemView.index,
      };
}

enum ImageQuality {
  VeryHigh('Very High', 'extraLarge'),
  High('High', 'large'),
  Medium('Medium', 'medium');

  const ImageQuality(this.label, this.value);

  final String label;
  final String value;
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

  factory AppMeta.fromMap(Map<String, dynamic> map) => AppMeta(
        lastNotificationId: map['lastNotificationId'] ?? -1,
        lastAppVersion: map['lastAppVersion'] ?? '',
        lastBackgroundJob: map['lastBackgroundJob'],
      );

  final int lastNotificationId;
  final String lastAppVersion;
  final DateTime? lastBackgroundJob;

  Map<String, dynamic> toMap() => {
        'lastNotificationId': lastNotificationId,
        'lastAppVersion': lastAppVersion,
        'lastBackgroundJob': lastBackgroundJob,
      };
}
