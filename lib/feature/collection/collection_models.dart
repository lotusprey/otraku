import 'package:otraku/extension/date_time_extension.dart';
import 'package:otraku/extension/iterable_extension.dart';
import 'package:otraku/feature/filter/filter_collection_model.dart';
import 'package:otraku/feature/viewer/persistence_model.dart';
import 'package:otraku/feature/media/media_models.dart';

typedef CollectionTag = ({int userId, bool ofAnime});

enum CollectionItemView { detailedList, simpleGrid }

sealed class Collection {
  const Collection({required this.scoreFormat});

  final ScoreFormat scoreFormat;

  List<Entry> get entries;
  String get listName;

  void sort(EntrySort s);
}

class PreviewCollection extends Collection {
  const PreviewCollection._({
    required this.entries,
    required super.scoreFormat,
  });

  factory PreviewCollection(
    Map<String, dynamic> map,
    ImageQuality imageQuality,
  ) {
    final entries = <Entry>[];
    for (final l in map['lists']) {
      if (l['isCustomList']) continue;

      for (final e in l['entries']) {
        entries.add(Entry(e, imageQuality));
      }
    }

    return PreviewCollection._(
      entries: entries,
      scoreFormat: ScoreFormat.from(
        map['user']['mediaListOptions']['scoreFormat'],
      ),
    );
  }

  @override
  final List<Entry> entries;

  @override
  String get listName => 'Preview';

  @override
  void sort(EntrySort s) {
    entries.sort(entryComparator(s));
  }
}

class FullCollection extends Collection {
  const FullCollection._({
    required this.lists,
    required this.index,
    required super.scoreFormat,
  });

  factory FullCollection(
    Map<String, dynamic> map,
    bool ofAnime,
    int index,
    ImageQuality imageQuality,
  ) {
    final maps = map['lists'] as List<dynamic>;
    final lists = <EntryList>[];
    final metaData =
        map['user']['mediaListOptions'][ofAnime ? 'animeList' : 'mangaList'];
    bool splitCompleted = metaData['splitCompletedSectionByFormat'] ?? false;

    for (final String section in metaData['sectionOrder']) {
      final pos = maps.indexWhere((l) => l['name'] == section);
      if (pos == -1) continue;

      final l = maps.removeAt(pos);

      lists.add(EntryList(l, splitCompleted, imageQuality));
    }

    for (final l in maps) {
      lists.add(EntryList(l, splitCompleted, imageQuality));
    }

    if (index >= lists.length) index = 0;

    return FullCollection._(
      lists: lists,
      index: index,
      scoreFormat: ScoreFormat.from(
        map['user']['mediaListOptions']['scoreFormat'],
      ),
    );
  }

  final List<EntryList> lists;
  final int index;

  @override
  List<Entry> get entries => lists.isEmpty ? const [] : lists[index].entries;

  @override
  String get listName => lists.isEmpty ? '' : lists[index].name;

  @override
  void sort(EntrySort s) {
    final comparator = entryComparator(s);
    for (final l in lists) {
      l.entries.sort(comparator);
    }
  }

  FullCollection withIndex(int newIndex) => newIndex == index
      ? this
      : FullCollection._(
          lists: lists,
          index: newIndex,
          scoreFormat: scoreFormat,
        );
}

class EntryList {
  EntryList._({
    required this.name,
    required this.entries,
    required this.status,
    required this.splitCompletedListFormat,
  });

  factory EntryList(
    Map<String, dynamic> map,
    bool splitCompleted,
    ImageQuality imageQuality,
  ) {
    final status =
        !map['isCustomList'] ? EntryStatus.from(map['status']) : null;

    return EntryList._(
      name: map['name'],
      status: status,
      splitCompletedListFormat:
          splitCompleted && status == EntryStatus.completed
              ? MediaFormat.from(map['entries'][0]['media']['format'])
              : null,
      entries: (map['entries'] as List<dynamic>)
          .map((e) => Entry(e, imageQuality))
          .toList(),
    );
  }

  final String name;
  final List<Entry> entries;

  /// The [EntryStatus] of the [entries] in this list.
  /// If `null`, this is a custom list.
  final EntryStatus? status;

  /// If the user's "completed" list is split by format and this is one of the
  /// resulting lists, [splitCompletedListFormat] is the corresponding format.
  final MediaFormat? splitCompletedListFormat;

  void removeByMediaId(int id) {
    for (int i = 0; i < entries.length; i++) {
      if (id == entries[i].mediaId) {
        entries.removeAt(i);
        return;
      }
    }
  }

  void insertSorted(Entry item, EntrySort s) {
    final compare = entryComparator(s);
    for (int i = 0; i < entries.length; i++) {
      if (compare(item, entries[i]) <= 0) {
        entries.insert(i, item);
        return;
      }
    }
    entries.add(item);
  }

  void sort(EntrySort s) => entries.sort(entryComparator(s));
}

int Function(Entry, Entry) entryComparator(EntrySort s) => switch (s) {
      EntrySort.title => (a, b) =>
          a.titles[0].toUpperCase().compareTo(b.titles[0].toUpperCase()),
      EntrySort.titleDesc => (a, b) => b.titles[0].compareTo(a.titles[0]),
      EntrySort.score => (a, b) {
          final comparison = a.score.compareTo(b.score);
          if (comparison != 0) return comparison;
          return a.titles[0].toUpperCase().compareTo(b.titles[0].toUpperCase());
        },
      EntrySort.scoreDesc => (a, b) {
          final comparison = b.score.compareTo(a.score);
          if (comparison != 0) return comparison;
          return a.titles[0].toUpperCase().compareTo(b.titles[0].toUpperCase());
        },
      EntrySort.updated => (a, b) {
          final comparison = a.updatedAt!.compareTo(b.updatedAt!);
          if (comparison != 0) return comparison;
          return a.titles[0].toUpperCase().compareTo(b.titles[0].toUpperCase());
        },
      EntrySort.updatedDesc => (a, b) {
          final comparison = b.updatedAt!.compareTo(a.updatedAt!);
          if (comparison != 0) return comparison;
          return a.titles[0].toUpperCase().compareTo(b.titles[0].toUpperCase());
        },
      EntrySort.added => (a, b) {
          final comparison = a.createdAt!.compareTo(b.createdAt!);
          if (comparison != 0) return comparison;
          return a.titles[0].toUpperCase().compareTo(b.titles[0].toUpperCase());
        },
      EntrySort.addedDesc => (a, b) {
          final comparison = b.createdAt!.compareTo(a.createdAt!);
          if (comparison != 0) return comparison;
          return a.titles[0].toUpperCase().compareTo(b.titles[0].toUpperCase());
        },
      EntrySort.progress => (a, b) {
          final comparison = a.progress.compareTo(b.progress);
          if (comparison != 0) return comparison;
          return a.titles[0].toUpperCase().compareTo(b.titles[0].toUpperCase());
        },
      EntrySort.progressDesc => (a, b) {
          final comparison = b.progress.compareTo(a.progress);
          if (comparison != 0) return comparison;
          return a.titles[0].toUpperCase().compareTo(b.titles[0].toUpperCase());
        },
      EntrySort.repeated => (a, b) {
          final comparison = a.repeat.compareTo(b.repeat);
          if (comparison != 0) return comparison;
          return a.titles[0].toUpperCase().compareTo(b.titles[0].toUpperCase());
        },
      EntrySort.repeatedDesc => (a, b) {
          final comparison = b.repeat.compareTo(a.repeat);
          if (comparison != 0) return comparison;
          return a.titles[0].toUpperCase().compareTo(b.titles[0].toUpperCase());
        },
      EntrySort.airing => (a, b) {
          if (a.airingAt == null) {
            if (b.airingAt == null) {
              return a.titles[0]
                  .toUpperCase()
                  .compareTo(b.titles[0].toUpperCase());
            }
            return 1;
          }

          if (b.airingAt == null) return -1;

          final comparison = a.airingAt!.compareTo(b.airingAt!);
          if (comparison != 0) return comparison;
          return a.titles[0].toUpperCase().compareTo(b.titles[0].toUpperCase());
        },
      EntrySort.airingDesc => (a, b) {
          if (b.airingAt == null) {
            if (a.airingAt == null) {
              return a.titles[0]
                  .toUpperCase()
                  .compareTo(b.titles[0].toUpperCase());
            }
            return -1;
          }

          if (a.airingAt == null) return 1;

          final comparison = b.airingAt!.compareTo(a.airingAt!);
          if (comparison != 0) return comparison;
          return a.titles[0].toUpperCase().compareTo(b.titles[0].toUpperCase());
        },
      EntrySort.releasedOn => (a, b) {
          if (a.releaseStart == null) {
            if (b.releaseStart == null) {
              return a.titles[0]
                  .toUpperCase()
                  .compareTo(b.titles[0].toUpperCase());
            }
            return 1;
          }

          if (b.releaseStart == null) return -1;

          final comparison = a.releaseStart!.compareTo(b.releaseStart!);
          if (comparison != 0) return comparison;
          return a.titles[0].toUpperCase().compareTo(b.titles[0].toUpperCase());
        },
      EntrySort.releasedOnDesc => (a, b) {
          if (b.releaseStart == null) {
            if (a.releaseStart == null) {
              return a.titles[0]
                  .toUpperCase()
                  .compareTo(b.titles[0].toUpperCase());
            }
            return -1;
          }

          if (a.releaseStart == null) return 1;

          final comparison = b.releaseStart!.compareTo(a.releaseStart!);
          if (comparison != 0) return comparison;
          return a.titles[0].toUpperCase().compareTo(b.titles[0].toUpperCase());
        },
      EntrySort.startedOn => (a, b) {
          if (a.watchStart == null) {
            if (b.watchStart == null) {
              return a.titles[0]
                  .toUpperCase()
                  .compareTo(b.titles[0].toUpperCase());
            }
            return 1;
          }

          if (b.watchStart == null) return -1;

          final comparison = a.watchStart!.compareTo(b.watchStart!);
          if (comparison != 0) return comparison;
          return a.titles[0].toUpperCase().compareTo(b.titles[0].toUpperCase());
        },
      EntrySort.startedOnDesc => (a, b) {
          if (b.watchStart == null) {
            if (a.watchStart == null) {
              return a.titles[0]
                  .toUpperCase()
                  .compareTo(b.titles[0].toUpperCase());
            }
            return -1;
          }

          if (a.watchStart == null) return 1;

          final comparison = b.watchStart!.compareTo(a.watchStart!);
          if (comparison != 0) return comparison;
          return a.titles[0].toUpperCase().compareTo(b.titles[0].toUpperCase());
        },
      EntrySort.completedOn => (a, b) {
          if (a.watchEnd == null) {
            if (b.watchEnd == null) {
              return a.titles[0]
                  .toUpperCase()
                  .compareTo(b.titles[0].toUpperCase());
            }
            return 1;
          }

          if (b.watchEnd == null) return -1;

          final comparison = a.watchEnd!.compareTo(b.watchEnd!);
          if (comparison != 0) return comparison;
          return a.titles[0].toUpperCase().compareTo(b.titles[0].toUpperCase());
        },
      EntrySort.completedOnDesc => (a, b) {
          if (b.watchEnd == null) {
            if (a.watchEnd == null) {
              return a.titles[0]
                  .toUpperCase()
                  .compareTo(b.titles[0].toUpperCase());
            }
            return -1;
          }

          if (a.watchEnd == null) return 1;

          final comparison = b.watchEnd!.compareTo(a.watchEnd!);
          if (comparison != 0) return comparison;
          return a.titles[0].toUpperCase().compareTo(b.titles[0].toUpperCase());
        },
      EntrySort.avgScore => (a, b) {
          if (a.avgScore == null) {
            if (b.avgScore == null) {
              return a.titles[0]
                  .toUpperCase()
                  .compareTo(b.titles[0].toUpperCase());
            }
            return 1;
          }

          if (b.avgScore == null) return -1;

          final comparison = a.avgScore!.compareTo(b.avgScore!);
          if (comparison != 0) return comparison;
          return a.titles[0].toUpperCase().compareTo(b.titles[0].toUpperCase());
        },
      EntrySort.avgScoreDesc => (a, b) {
          if (b.avgScore == null) {
            if (a.avgScore == null) {
              return a.titles[0]
                  .toUpperCase()
                  .compareTo(b.titles[0].toUpperCase());
            }
            return -1;
          }

          if (a.avgScore == null) return 1;

          final comparison = b.avgScore!.compareTo(a.avgScore!);
          if (comparison != 0) return comparison;
          return a.titles[0].toUpperCase().compareTo(b.titles[0].toUpperCase());
        },
    };

class Entry {
  Entry._({
    required this.mediaId,
    required this.titles,
    required this.imageUrl,
    required this.format,
    required this.status,
    required this.entryStatus,
    required this.nextEpisode,
    required this.airingAt,
    required this.createdAt,
    required this.updatedAt,
    required this.country,
    required this.isPrivate,
    required this.genres,
    required this.tags,
    required this.progressMax,
    required this.progress,
    required this.repeat,
    required this.score,
    required this.notes,
    required this.avgScore,
    required this.releaseStart,
    required this.watchStart,
    required this.watchEnd,
  });

  factory Entry(Map<String, dynamic> map, ImageQuality imageQuality) {
    final titles = <String>[map['media']['title']['userPreferred']];
    if (map['media']['title']['english'] != null) {
      titles.add(map['media']['title']['english']);
    }
    if (map['media']['title']['romaji'] != null) {
      titles.add(map['media']['title']['romaji']);
    }
    if (map['media']['title']['native'] != null) {
      titles.add(map['media']['title']['native']);
    }

    final tags = <int>[];
    for (final t in map['media']['tags']) {
      tags.add(t['id']);
    }

    return Entry._(
      mediaId: map['media']['id'],
      titles: titles,
      imageUrl: map['media']['coverImage'][imageQuality.value],
      format: MediaFormat.from(map['media']['format']),
      status: ReleaseStatus.from(map['media']['status']),
      entryStatus: EntryStatus.from(map['status']),
      nextEpisode: map['media']['nextAiringEpisode']?['episode'],
      airingAt: DateTimeExtension.tryFromSecondsSinceEpoch(
        map['media']['nextAiringEpisode']?['airingAt'],
      ),
      createdAt: map['createdAt'],
      updatedAt: map['updatedAt'],
      country: map['media']['countryOfOrigin'],
      isPrivate: map['private'] ?? false,
      genres: List.from(map['media']['genres'] ?? [], growable: false),
      tags: tags,
      progressMax: map['media']['episodes'] ?? map['media']['chapters'],
      progress: map['progress'] ?? 0,
      repeat: map['repeat'] ?? 0,
      score: map['score'].toDouble() ?? 0.0,
      notes: map['notes'] ?? '',
      avgScore: map['media']['averageScore'],
      releaseStart: DateTimeExtension.fromFuzzyDate(map['media']['startDate']),
      watchStart: DateTimeExtension.fromFuzzyDate(map['startedAt']),
      watchEnd: DateTimeExtension.fromFuzzyDate(map['completedAt']),
    );
  }

  final int mediaId;
  final List<String> titles;
  final String imageUrl;
  final MediaFormat? format;
  final ReleaseStatus? status;
  final EntryStatus? entryStatus;
  final int? nextEpisode;
  final DateTime? airingAt;
  final int? createdAt;
  final int? updatedAt;
  final String? country;
  final bool isPrivate;
  final List<String> genres;
  final List<int> tags;
  final int? progressMax;
  int progress;
  int repeat;
  double score;
  String notes;
  int? avgScore;
  DateTime? releaseStart;
  DateTime? watchStart;
  DateTime? watchEnd;
}

enum EntryStatus {
  current('CURRENT'),
  planning('PLANNING'),
  completed('COMPLETED'),
  dropped('DROPPED'),
  paused('PAUSED'),
  repeating('REPEATING');

  const EntryStatus(this.value);

  final String value;

  String label(bool? ofAnime) => switch (this) {
        current => ofAnime == null
            ? 'Current'
            : ofAnime
                ? 'Watching'
                : 'Reading',
        repeating => ofAnime == null
            ? 'Repeating'
            : ofAnime
                ? 'Rewatching'
                : 'Rereading',
        completed => 'Completed',
        paused => 'Paused',
        planning => 'Planning',
        dropped => 'Dropped',
      };

  static EntryStatus? from(String? value) =>
      EntryStatus.values.firstWhereOrNull((v) => v.value == value);
}

class CollectionFilter {
  const CollectionFilter._({required this.search, required this.mediaFilter});

  CollectionFilter(bool ofAnime)
      : search = '',
        mediaFilter = CollectionMediaFilter(ofAnime);

  final String search;
  final CollectionMediaFilter mediaFilter;

  CollectionFilter copyWith({
    String? search,
    CollectionMediaFilter? mediaFilter,
  }) =>
      CollectionFilter._(
        search: search ?? this.search,
        mediaFilter: mediaFilter ?? this.mediaFilter,
      );
}
