import 'package:otraku/modules/filter/filter_models.dart';
import 'package:otraku/modules/media/media_constants.dart';
import 'package:otraku/common/utils/convert.dart';
import 'package:otraku/common/utils/options.dart';

typedef CollectionTag = ({int userId, bool ofAnime});

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

class EntryList {
  EntryList._({
    required this.name,
    required this.entries,
    required this.status,
    required this.splitCompletedListFormat,
  });

  factory EntryList(Map<String, dynamic> map, bool splitCompleted) {
    final status = !map['isCustomList'] && map['status'] != null
        ? EntryStatus.values.byName(map['status'])
        : null;

    return EntryList._(
      name: map['name'],
      status: status,
      splitCompletedListFormat:
          splitCompleted && status == EntryStatus.COMPLETED
              ? map['entries'][0]['media']['format']
              : null,
      entries: (map['entries'] as List<dynamic>).map((e) => Entry(e)).toList(),
    );
  }

  final String name;
  final List<Entry> entries;

  /// The [EntryStatus] of the [entries] in this list.
  /// If `null`, this is a custom list.
  final EntryStatus? status;

  /// If the user's "completed" list is split by format and this is one of the
  /// resulting lists, this holds the corresponding [AnimeFormat] or
  /// [MangaFormat]. Parsing the `String` is unnecessary for now.
  /// The value is `null`, if the list doesn't fulfill the
  /// aforementioned conditions.
  final String? splitCompletedListFormat;

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
      EntrySort.TITLE => (a, b) =>
          a.titles[0].toUpperCase().compareTo(b.titles[0].toUpperCase()),
      EntrySort.TITLE_DESC => (a, b) => b.titles[0].compareTo(a.titles[0]),
      EntrySort.SCORE => (a, b) {
          final comparison = a.score.compareTo(b.score);
          if (comparison != 0) return comparison;
          return a.titles[0].toUpperCase().compareTo(b.titles[0].toUpperCase());
        },
      EntrySort.SCORE_DESC => (a, b) {
          final comparison = b.score.compareTo(a.score);
          if (comparison != 0) return comparison;
          return a.titles[0].toUpperCase().compareTo(b.titles[0].toUpperCase());
        },
      EntrySort.UPDATED => (a, b) {
          final comparison = a.updatedAt!.compareTo(b.updatedAt!);
          if (comparison != 0) return comparison;
          return a.titles[0].toUpperCase().compareTo(b.titles[0].toUpperCase());
        },
      EntrySort.UPDATED_DESC => (a, b) {
          final comparison = b.updatedAt!.compareTo(a.updatedAt!);
          if (comparison != 0) return comparison;
          return a.titles[0].toUpperCase().compareTo(b.titles[0].toUpperCase());
        },
      EntrySort.ADDED => (a, b) {
          final comparison = a.createdAt!.compareTo(b.createdAt!);
          if (comparison != 0) return comparison;
          return a.titles[0].toUpperCase().compareTo(b.titles[0].toUpperCase());
        },
      EntrySort.ADDED_DESC => (a, b) {
          final comparison = b.createdAt!.compareTo(a.createdAt!);
          if (comparison != 0) return comparison;
          return a.titles[0].toUpperCase().compareTo(b.titles[0].toUpperCase());
        },
      EntrySort.PROGRESS => (a, b) {
          final comparison = a.progress.compareTo(b.progress);
          if (comparison != 0) return comparison;
          return a.titles[0].toUpperCase().compareTo(b.titles[0].toUpperCase());
        },
      EntrySort.PROGRESS_DESC => (a, b) {
          final comparison = b.progress.compareTo(a.progress);
          if (comparison != 0) return comparison;
          return a.titles[0].toUpperCase().compareTo(b.titles[0].toUpperCase());
        },
      EntrySort.REPEATED => (a, b) {
          final comparison = a.repeat.compareTo(b.repeat);
          if (comparison != 0) return comparison;
          return a.titles[0].toUpperCase().compareTo(b.titles[0].toUpperCase());
        },
      EntrySort.REPEATED_DESC => (a, b) {
          final comparison = b.repeat.compareTo(a.repeat);
          if (comparison != 0) return comparison;
          return a.titles[0].toUpperCase().compareTo(b.titles[0].toUpperCase());
        },
      EntrySort.AIRING => (a, b) {
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
      EntrySort.AIRING_DESC => (a, b) {
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
      EntrySort.RELEASED_ON => (a, b) {
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
      EntrySort.RELEASED_ON_DESC => (a, b) {
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
      EntrySort.STARTED_ON => (a, b) {
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
      EntrySort.STARTED_ON_DESC => (a, b) {
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
      EntrySort.COMPLETED_ON => (a, b) {
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
      EntrySort.COMPLETED_ON_DESC => (a, b) {
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
      EntrySort.AVG_SCORE => (a, b) {
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
      EntrySort.AVG_SCORE_DESC => (a, b) {
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
    required this.genres,
    required this.tags,
    required this.progress,
    required this.progressMax,
    required this.repeat,
    required this.score,
    required this.notes,
    required this.avgScore,
    required this.releaseStart,
    required this.watchStart,
    required this.watchEnd,
  });

  factory Entry(Map<String, dynamic> map) {
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
      imageUrl: map['media']['coverImage'][Options().imageQuality.value],
      format: map['media']['format'],
      status: map['media']['status'],
      entryStatus: EntryStatus.values.byName(map['status']),
      nextEpisode: map['media']['nextAiringEpisode']?['episode'],
      airingAt: map['media']['nextAiringEpisode']?['airingAt'],
      createdAt: map['createdAt'],
      updatedAt: map['updatedAt'],
      country: map['media']['countryOfOrigin'],
      genres: List.from(map['media']['genres'] ?? [], growable: false),
      tags: tags,
      progress: map['progress'] ?? 0,
      progressMax: map['media']['episodes'] ?? map['media']['chapters'],
      repeat: map['repeat'] ?? 0,
      score: map['score'].toDouble() ?? 0.0,
      notes: map['notes'],
      avgScore: map['media']['averageScore'],
      releaseStart: Convert.mapToMillis(map['media']['startDate']),
      watchStart: Convert.mapToMillis(map['startedAt']),
      watchEnd: Convert.mapToMillis(map['completedAt']),
    );
  }

  final int mediaId;
  final List<String> titles;
  final String imageUrl;
  final String? format;
  final String? status;
  final EntryStatus? entryStatus;
  final int? nextEpisode;
  final int? airingAt;
  final int? createdAt;
  final int? updatedAt;
  final String? country;
  final List<String> genres;
  final List<int> tags;
  int progress;
  final int? progressMax;
  int repeat;
  double score;
  String? notes;
  int? avgScore;
  int? releaseStart;
  int? watchStart;
  int? watchEnd;
}

enum EntryStatus {
  CURRENT,
  PLANNING,
  COMPLETED,
  DROPPED,
  PAUSED,
  REPEATING,
}
