import 'package:otraku/extension/date_time_extension.dart';
import 'package:otraku/extension/iterable_extension.dart';
import 'package:otraku/feature/viewer/persistence_model.dart';
import 'package:otraku/feature/media/media_models.dart';

typedef CollectionTag = ({int userId, bool ofAnime});

enum CollectionItemView { detailed, simple }

sealed class Collection {
  const Collection({required this.scoreFormat});

  final ScoreFormat scoreFormat;

  EntryList get list;

  void sort(EntrySort s);
}

class PreviewCollection extends Collection {
  const PreviewCollection._({
    required this.list,
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
      list: EntryList._(
        name: 'Preview',
        entries: entries,
        status: null,
        splitCompletedListFormat: null,
      ),
      scoreFormat: ScoreFormat.from(
        map['user']['mediaListOptions']['scoreFormat'],
      ),
    );
  }

  @override
  final EntryList list;

  @override
  void sort(EntrySort s) {
    list.entries.sort(_entryComparator(s));
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
  EntryList get list => lists.isNotEmpty
      ? lists[index]
      : const EntryList._(
          name: '',
          entries: [],
          status: null,
          splitCompletedListFormat: null,
        );

  @override
  void sort(EntrySort s) {
    final comparator = _entryComparator(s);
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
  const EntryList._({
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
    final status = !map['isCustomList'] ? ListStatus.from(map['status']) : null;

    return EntryList._(
      name: map['name'],
      status: status,
      splitCompletedListFormat: splitCompleted && status == ListStatus.completed
          ? MediaFormat.from(map['entries'][0]['media']['format'])
          : null,
      entries: (map['entries'] as List<dynamic>)
          .map((e) => Entry(e, imageQuality))
          .toList(),
    );
  }

  final String name;
  final List<Entry> entries;

  /// The [ListStatus] of the [entries] in this list.
  /// If `null`, this is a custom list.
  final ListStatus? status;

  /// If the user's "completed" list is split by format and this is one of the
  /// resulting lists, [splitCompletedListFormat] is the corresponding format.
  final MediaFormat? splitCompletedListFormat;

  bool setByMediaId(Entry entry) {
    for (int i = 0; i < entries.length; i++) {
      if (entries[i].mediaId == entry.mediaId) {
        entries[i] = entry;
        return true;
      }
    }
    return false;
  }

  void removeByMediaId(int id) {
    for (int i = 0; i < entries.length; i++) {
      if (entries[i].mediaId == id) {
        entries.removeAt(i);
        return;
      }
    }
  }

  void insertSorted(Entry entry, EntrySort s) {
    final compare = _entryComparator(s);
    for (int i = 0; i < entries.length; i++) {
      if (compare(entry, entries[i]) <= 0) {
        entries.insert(i, entry);
        return;
      }
    }
    entries.add(entry);
  }

  void sort(EntrySort s) => entries.sort(_entryComparator(s));
}

/// Returns a [Comparator] for [Entry], based on an [EntrySort].
int Function(Entry, Entry) _entryComparator(EntrySort s) => switch (s) {
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
    required this.releaseStatus,
    required this.listStatus,
    required this.nextEpisode,
    required this.airingAt,
    required this.createdAt,
    required this.updatedAt,
    required this.country,
    required this.isPrivate,
    required this.genres,
    required this.tagIds,
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

    final tagIds = <int>[];
    for (final t in map['media']['tags']) {
      tagIds.add(t['id']);
    }

    return Entry._(
      mediaId: map['media']['id'],
      titles: titles,
      imageUrl: map['media']['coverImage'][imageQuality.value],
      format: MediaFormat.from(map['media']['format']),
      releaseStatus: ReleaseStatus.from(map['media']['status']),
      listStatus: ListStatus.from(map['status']),
      nextEpisode: map['media']['nextAiringEpisode']?['episode'],
      airingAt: DateTimeExtension.tryFromSecondsSinceEpoch(
        map['media']['nextAiringEpisode']?['airingAt'],
      ),
      createdAt: map['createdAt'],
      updatedAt: map['updatedAt'],
      country: map['media']['countryOfOrigin'],
      isPrivate: map['private'] ?? false,
      genres: List.from(map['media']['genres'] ?? [], growable: false),
      tagIds: tagIds,
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
  final ReleaseStatus? releaseStatus;
  final ListStatus? listStatus;
  final int? nextEpisode;
  final DateTime? airingAt;
  final int? createdAt;
  final int? updatedAt;
  final String? country;
  final bool isPrivate;
  final List<String> genres;
  final List<int> tagIds;
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

enum ListStatus {
  current('CURRENT'),
  planning('PLANNING'),
  completed('COMPLETED'),
  dropped('DROPPED'),
  paused('PAUSED'),
  repeating('REPEATING');

  const ListStatus(this.value);

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

  static ListStatus? from(String? value) =>
      ListStatus.values.firstWhereOrNull((v) => v.value == value);
}
